abstract class PersistableService {
  /// Save the current state to a JSON file.
  Future<void> saveToJson();

  /// Load and restore state from a JSON file.
  Future<void> loadFromJson();
}
