import 'package:pub_semver/pub_semver.dart';

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
    try {
      final cleanCurrent = current.trim().replaceFirst(RegExp(r'^[vV]'), '');
      final cleanRemote = remote.trim().replaceFirst(RegExp(r'^[vV]'), '');
      final vCurrent = Version.parse(cleanCurrent);
      final vRemote = Version.parse(cleanRemote);
      return vRemote > vCurrent;
    } catch (_) {
      return false;
    }
  }
}
