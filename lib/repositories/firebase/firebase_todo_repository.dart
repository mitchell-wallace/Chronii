import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/todo_model.dart';
import '../base/todo_repository.dart';

/// Implementation of TodoRepository that uses Firebase Firestore for cloud storage
class FirebaseTodoRepository implements TodoRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  late CollectionReference<Map<String, dynamic>> _todosCollection;
  
  FirebaseTodoRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : 
    _firestore = firestore ?? FirebaseFirestore.instance,
    _auth = auth ?? FirebaseAuth.instance;
  
  @override
  Future<void> init() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }
    
    _todosCollection = _firestore.collection('users').doc(user.uid).collection('todos');
  }
  
  @override
  Future<List<Todo>> getAll() async {
    final snapshot = await _todosCollection.get();
    return snapshot.docs.map((doc) => Todo.fromJson(doc.data())).toList();
  }
  
  @override
  Future<Todo?> getById(String id) async {
    final doc = await _todosCollection.doc(id).get();
    if (!doc.exists) return null;
    return Todo.fromJson(doc.data()!);
  }
  
  @override
  Future<Todo> add(Todo todo) async {
    await _todosCollection.doc(todo.id).set(todo.toJson());
    return todo;
  }
  
  @override
  Future<bool> update(Todo updatedTodo) async {
    try {
      updatedTodo.updatedAt = DateTime.now();
      await _todosCollection.doc(updatedTodo.id).update(updatedTodo.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<bool> delete(String id) async {
    try {
      await _todosCollection.doc(id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<List<Todo>> getCompleted() async {
    final snapshot = await _todosCollection.where('isCompleted', isEqualTo: true).get();
    return snapshot.docs.map((doc) => Todo.fromJson(doc.data())).toList();
  }
  
  @override
  Future<List<Todo>> getIncomplete() async {
    final snapshot = await _todosCollection.where('isCompleted', isEqualTo: false).get();
    return snapshot.docs.map((doc) => Todo.fromJson(doc.data())).toList();
  }
  
  @override
  Future<bool> toggleCompletion(String id) async {
    try {
      final doc = await _todosCollection.doc(id).get();
      if (!doc.exists) return false;
      
      final todo = Todo.fromJson(doc.data()!);
      todo.toggleCompletion();
      
      await _todosCollection.doc(id).update({
        'isCompleted': todo.isCompleted,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<int> deleteCompleted() async {
    final batch = _firestore.batch();
    final snapshot = await _todosCollection.where('isCompleted', isEqualTo: true).get();
    
    final count = snapshot.docs.length;
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
    return count;
  }
  
  @override
  Future<int> markAllAsCompleted() async {
    final batch = _firestore.batch();
    final now = DateTime.now().toIso8601String();
    final snapshot = await _todosCollection.where('isCompleted', isEqualTo: false).get();
    
    final count = snapshot.docs.length;
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'isCompleted': true,
        'updatedAt': now,
      });
    }
    
    await batch.commit();
    return count;
  }
  
  @override
  Future<int> markAllAsIncomplete() async {
    final batch = _firestore.batch();
    final now = DateTime.now().toIso8601String();
    final snapshot = await _todosCollection.where('isCompleted', isEqualTo: true).get();
    
    final count = snapshot.docs.length;
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'isCompleted': false,
        'updatedAt': now,
      });
    }
    
    await batch.commit();
    return count;
  }
}
