import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/timer_model.dart';
import '../base/timer_repository.dart';

/// Implementation of TimerRepository that uses Firebase Firestore for cloud storage
class FirebaseTimerRepository implements TimerRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  late CollectionReference<Map<String, dynamic>> _timersCollection;
  
  FirebaseTimerRepository({
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
    
    _timersCollection = _firestore.collection('users').doc(user.uid).collection('timers');
  }
  
  @override
  Future<List<TaskTimer>> getAll() async {
    final snapshot = await _timersCollection.get();
    return snapshot.docs.map((doc) => TaskTimer.fromJson(doc.data())).toList();
  }
  
  @override
  Future<TaskTimer?> getById(String id) async {
    final doc = await _timersCollection.doc(id).get();
    if (!doc.exists) return null;
    return TaskTimer.fromJson(doc.data()!);
  }
  
  @override
  Future<TaskTimer> add(TaskTimer timer) async {
    await _timersCollection.doc(timer.id).set(timer.toJson());
    return timer;
  }
  
  @override
  Future<bool> update(TaskTimer updatedTimer) async {
    try {
      await _timersCollection.doc(updatedTimer.id).update(updatedTimer.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<bool> delete(String id) async {
    try {
      await _timersCollection.doc(id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<List<TaskTimer>> getRunningTimers() async {
    final snapshot = await _timersCollection.where('endTime', isNull: true).get();
    return snapshot.docs.map((doc) => TaskTimer.fromJson(doc.data())).toList();
  }
  
  @override
  Future<TaskTimer?> toggleTimer(String id) async {
    try {
      final doc = await _timersCollection.doc(id).get();
      if (!doc.exists) return null;
      
      final timer = TaskTimer.fromJson(doc.data()!);
      TaskTimer? newTimer;
      
      if (timer.isRunning) {
        // Stop the timer
        timer.stop();
        await _timersCollection.doc(id).update({
          'endTime': timer.endTime?.toIso8601String(),
        });
      } else {
        // Create a new timer with same name
        newTimer = timer.createNewSession();
        await _timersCollection.doc(newTimer.id).set(newTimer.toJson());
      }
      
      return newTimer ?? timer;
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<void> stopAllRunningTimers() async {
    final now = DateTime.now().toIso8601String();
    final batch = _firestore.batch();
    final snapshot = await _timersCollection.where('endTime', isNull: true).get();
    
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'endTime': now,
      });
    }
    
    await batch.commit();
  }
  
  @override
  Duration calculateTotalDuration(List<String> timerIds, DateTime currentTime) {
    // Note: This is implemented locally since it's a calculation and doesn't require
    // a Firebase operation. In a real app, you might want to create a Cloud Function
    // for this calculation if dealing with large datasets.
    Duration totalDuration = Duration.zero;
    
    // This would be implemented fully in a real app context
    // Right now it's placeholder for the interface compliance
    
    return totalDuration;
  }
}
