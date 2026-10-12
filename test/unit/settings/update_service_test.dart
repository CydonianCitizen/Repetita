import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/features/settings/data/update_service.dart';
import 'package:repetita/src/features/settings/domain/update_info.dart';

void main() {
  group('UpdateInfo Unit Tests', () {
    test('isRemoteNewer compares semantic versions correctly', () {
      expect(UpdateInfo.isRemoteNewer('0.0.5', '0.0.6'), isTrue);
      expect(UpdateInfo.isRemoteNewer('v0.0.5', 'v0.0.6'), isTrue);
      expect(UpdateInfo.isRemoteNewer('0.0.5', '0.1.0'), isTrue);
      expect(UpdateInfo.isRemoteNewer('0.0.5', '1.0.0'), isTrue);

      expect(UpdateInfo.isRemoteNewer('0.0.5', '0.0.5'), isFalse);
      expect(UpdateInfo.isRemoteNewer('v0.0.5', 'v0.0.5'), isFalse);
      expect(UpdateInfo.isRemoteNewer('0.0.6', '0.0.5'), isFalse);
      expect(UpdateInfo.isRemoteNewer('0.1.0', '0.0.9'), isFalse);
      expect(UpdateInfo.isRemoteNewer('1.0.0', '0.9.9'), isFalse);
    });
  });

  group('UpdateService Unit Tests', () {
    test(
      'checkForUpdates parses successful GitHub release payload correctly',
      () async {
        const mockPayload = '''
      {
        "tag_name": "v0.1.0",
        "html_url": "https://github.com/CydonianCitizen/Repetita/releases/tag/v0.1.0",
        "body": "New FSRS enhancements and UI polish.",
        "published_at": "2026-10-11T10:00:00Z"
      }
      ''';

        final service = UpdateService(fetcher: (uri) async => mockPayload);

        final result = await service.checkForUpdates(currentVersion: 'v0.0.5');

        expect(result.currentVersion, 'v0.0.5');
        expect(result.latestVersion, 'v0.1.0');
        expect(result.hasUpdate, isTrue);
        expect(result.releaseNotes, 'New FSRS enhancements and UI polish.');
        expect(result.releaseUrl, contains('v0.1.0'));
        expect(result.publishedAt, isNotNull);
      },
    );

    test(
      'checkForUpdates detects when current version is up to date',
      () async {
        const mockPayload = '''
      {
        "tag_name": "v0.0.5",
        "html_url": "https://github.com/CydonianCitizen/Repetita/releases/tag/v0.0.5",
        "body": "Initial release."
      }
      ''';

        final service = UpdateService(fetcher: (uri) async => mockPayload);

        final result = await service.checkForUpdates(currentVersion: 'v0.0.5');

        expect(result.hasUpdate, isFalse);
        expect(result.latestVersion, 'v0.0.5');
      },
    );

    test(
      'checkForUpdates bubbles handled UpdateCheckException on error',
      () async {
        final service = UpdateService(
          fetcher: (uri) async =>
              throw const UpdateCheckException('Offline error'),
        );

        expect(
          () => service.checkForUpdates(currentVersion: 'v0.0.5'),
          throwsA(isA<UpdateCheckException>()),
        );
      },
    );

    test('checkForUpdates handles malformed JSON string gracefully', () async {
      final service = UpdateService(
        fetcher: (uri) async => 'invalid-json-content{{{',
      );

      expect(
        () => service.checkForUpdates(currentVersion: 'v0.0.5'),
        throwsA(isA<UpdateCheckException>()),
      );
    });

    test('checkForUpdates handles non-object JSON array gracefully', () async {
      final service = UpdateService(
        fetcher: (uri) async => '[{"tag_name": "v0.1.0"}]',
      );

      expect(
        () => service.checkForUpdates(currentVersion: 'v0.0.5'),
        throwsA(isA<UpdateCheckException>()),
      );
    });
  });
}
