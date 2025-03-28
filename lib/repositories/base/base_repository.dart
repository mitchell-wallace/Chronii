/// Generic repository interface for CRUD operations
/// Acts as the foundation for all data access in the app
abstract class BaseRepository<T> {
  /// Get all items
  Future<List<T>> getAll();
  
  /// Get a specific item by its ID
  Future<T?> getById(String id);
  
  /// Add a new item
  Future<T> add(T item);
  
  /// Update an existing item
  Future<bool> update(T item);
  
  /// Delete an item by its ID
  Future<bool> delete(String id);
  
  /// Initialize the repository
  Future<void> init();
}
