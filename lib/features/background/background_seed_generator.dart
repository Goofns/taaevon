/// Derives a deterministic integer seed from a user identifier so that the
/// background polygon field is stable for a given user but varies across users.
abstract class BackgroundSeedGenerator {
  /// Stable, platform-independent seed from any string id (e.g. user id).
  /// Uses a 32-bit FNV-1a hash so the same id always yields the same layout.
  static int fromUserId(String userId) {
    const int fnvPrime = 0x01000193;
    int hash = 0x811c9dc5;
    for (final codeUnit in userId.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * fnvPrime) & 0xFFFFFFFF;
    }
    return hash;
  }

  /// Fallback seed for anonymous / first-run sessions.
  static int get anonymous => fromUserId('taaevon-anonymous');
}
