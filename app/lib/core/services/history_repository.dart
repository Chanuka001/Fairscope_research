import '../models/scan_record.dart';

/// Abstract storage repository for analysed scan records.
///
/// Privacy & Architecture guarantees:
/// - Stored exclusively in the application's private on-device directory.
/// - Never synced to external servers or cloud storage.
/// - Delete performs complete and permanent removal of all files (JSON and image).
/// - Unanalysed captures are never saved here.
abstract class HistoryRepository {
  /// Retrieves all saved scan records ordered with newest first.
  Future<List<ScanRecord>> getAllRecords();

  /// Retrieves a specific scan record by its ID (e.g., "FS-0001").
  Future<ScanRecord?> getRecordById(String id);

  /// Saves a newly analysed scan record to private device storage.
  Future<void> saveRecord(ScanRecord record);

  /// Updates the user label for an existing record.
  /// User labels must be anonymized and not contain real names.
  Future<void> updateLabel(String id, String newLabel);

  /// Permanently deletes a scan record and its associated image from device storage.
  Future<bool> deleteRecord(String id);

  /// Generates the next sequential ID (e.g. "FS-0001", "FS-0002").
  Future<String> nextRecordId();

  /// Completely clears all history records and files.
  Future<void> clearAll();
}

