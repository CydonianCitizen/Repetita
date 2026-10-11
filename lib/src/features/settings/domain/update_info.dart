class UpdateInfo {
  const UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.hasUpdate,
    required this.releaseUrl,
    this.releaseNotes,
    this.publishedAt,
  });

  final String currentVersion;
  final String latestVersion;
  final bool hasUpdate;
  final String releaseUrl;
  final String? releaseNotes;
  final DateTime? publishedAt;

  static bool isRemoteNewer(String current, String remote) {
    final cleanCurrent = _normalizeVersion(current);
    final cleanRemote = _normalizeVersion(remote);

    for (var i = 0; i < 3; i++) {
      final c = i < cleanCurrent.length ? cleanCurrent[i] : 0;
      final r = i < cleanRemote.length ? cleanRemote[i] : 0;
      if (r > c) return true;
      if (r < c) return false;
    }
    return false;
  }

  static List<int> _normalizeVersion(String v) {
    final stripped = v.trim().replaceFirst(RegExp(r'^[vV]'), '');
    final parts = stripped.split(RegExp(r'[-+]'))[0].split('.');
    return parts.map((p) => int.tryParse(p) ?? 0).toList();
  }
}
