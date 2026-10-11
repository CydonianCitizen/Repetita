import 'dart:convert';
import 'dart:io';

import '../domain/update_info.dart';

class UpdateCheckException implements Exception {
  const UpdateCheckException(this.message);
  final String message;

  @override
  String toString() => message;
}

typedef ReleaseDataFetcher = Future<String> Function(Uri uri);

class UpdateService {
  UpdateService({
    this.repoOwner = 'CydonianCitizen',
    this.repoName = 'Repetita',
    ReleaseDataFetcher? fetcher,
  }) : _fetcher = fetcher ?? _defaultFetcher;

  final String repoOwner;
  final String repoName;
  final ReleaseDataFetcher _fetcher;

  static Future<String> _defaultFetcher(Uri uri) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 6);

    try {
      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.userAgentHeader, 'Repetita-App');
      request.headers.set(
        HttpHeaders.acceptHeader,
        'application/vnd.github.v3+json',
      );

      final response = await request.close().timeout(
        const Duration(seconds: 6),
      );
      if (response.statusCode == HttpStatus.notFound) {
        // No releases published yet on this repository
        final segments = uri.pathSegments;
        final repoPath = segments.length >= 2
            ? '${segments[0]}/${segments[1]}'
            : '';
        return jsonEncode(<String, dynamic>{
          'tag_name': '',
          'html_url': 'https://github.com/$repoPath',
          'body': null,
          'published_at': null,
        });
      }
      if (response.statusCode == HttpStatus.forbidden) {
        throw const UpdateCheckException(
          'GitHub API rate limit reached. Please try again later.',
        );
      }
      if (response.statusCode != HttpStatus.ok) {
        throw UpdateCheckException(
          'GitHub returned status code ${response.statusCode}',
        );
      }

      final responseBody = await response.transform(utf8.decoder).join();
      return responseBody;
    } on SocketException catch (_) {
      throw const UpdateCheckException('Device appears to be offline.');
    } on HandshakeException catch (_) {
      throw const UpdateCheckException(
        'Secure connection could not be established.',
      );
    } on Exception catch (e) {
      if (e is UpdateCheckException) rethrow;
      throw UpdateCheckException('Failed to check for updates: $e');
    } finally {
      client.close();
    }
  }

  Future<UpdateInfo> checkForUpdates({required String currentVersion}) async {
    final uri = Uri.https(
      'api.github.com',
      '/repos/$repoOwner/$repoName/releases/latest',
    );

    final rawJson = await _fetcher(uri);
    final data = jsonDecode(rawJson) as Map<String, dynamic>;

    final tagName = data['tag_name'] as String? ?? '';
    final releaseUrl =
        data['html_url'] as String? ??
        'https://github.com/$repoOwner/$repoName/releases';
    final releaseNotes = data['body'] as String?;
    final publishedStr = data['published_at'] as String?;
    final publishedAt = publishedStr != null
        ? DateTime.tryParse(publishedStr)
        : null;

    final effectiveLatest = tagName.isEmpty ? currentVersion : tagName;
    final hasUpdate =
        tagName.isNotEmpty && UpdateInfo.isRemoteNewer(currentVersion, tagName);

    return UpdateInfo(
      currentVersion: currentVersion,
      latestVersion: effectiveLatest,
      hasUpdate: hasUpdate,
      releaseUrl: releaseUrl,
      releaseNotes: releaseNotes,
      publishedAt: publishedAt,
    );
  }
}
