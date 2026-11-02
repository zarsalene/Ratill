import 'dart:io';

import 'package:crypto/crypto.dart' as crypto;

/// The downloaded file is not the pinned file.
class ChecksumMismatch implements Exception {
  const ChecksumMismatch(this.name, this.expected, this.actual);
  final String name;
  final String expected;
  final String actual;

  @override
  String toString() => 'checksum mismatch for $name: expected $expected, got $actual';
}

/// Downloads [url] to [dest] and keeps it only if its SHA-256 equals [sha256].
///
/// The data goes to `<dest>.part`. A `.part` file left by an earlier try
/// resumes with a Range request. After the download the whole `.part` file is
/// hashed; on a mismatch (or a wrong length when [bytes] is known) it is
/// deleted, so the next try starts clean, and the error is thrown. Only a file
/// that passes is renamed to [dest]. A network error keeps the `.part` file.
Future<void> downloadVerified(
  Uri url,
  File dest, {
  required String sha256,
  int? bytes,
  void Function(double progress)? onProgress,
}) async {
  final part = File('${dest.path}.part');
  await dest.parent.create(recursive: true);
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 20);
  try {
    var have = await part.exists() ? await part.length() : 0;
    if (bytes != null && have > bytes) {
      await part.delete();
      have = 0;
    }
    if (bytes == null || have < bytes) {
      final req = await client.getUrl(url);
      if (have > 0) req.headers.set(HttpHeaders.rangeHeader, 'bytes=$have-');
      final res = await req.close();
      if (res.statusCode == HttpStatus.ok) {
        have = 0; // the server sent the whole file
      } else if (res.statusCode != HttpStatus.partialContent) {
        await res.drain<void>();
        throw HttpException('HTTP ${res.statusCode}', uri: url);
      }
      final total = bytes ?? (res.contentLength > 0 ? have + res.contentLength : -1);
      final sink = part.openWrite(mode: have == 0 ? FileMode.write : FileMode.append);
      var got = have;
      var lastNotify = DateTime.now();
      try {
        await for (final chunk in res) {
          sink.add(chunk);
          got += chunk.length;
          if (total > 0 && DateTime.now().difference(lastNotify).inMilliseconds > 250) {
            lastNotify = DateTime.now();
            onProgress?.call((got / total).clamp(0, 1));
          }
        }
      } finally {
        await sink.close();
      }
    }
    if (bytes != null) {
      final size = await part.length();
      if (size < bytes) throw const HttpException('incomplete download'); // keep the .part file: resume
      if (size > bytes) {
        await part.delete();
        throw const HttpException('download is longer than expected');
      }
    }
    final actual = (await sha256Of(part)).toLowerCase();
    if (actual != sha256.toLowerCase()) {
      await part.delete();
      throw ChecksumMismatch(dest.uri.pathSegments.last, sha256, actual);
    }
    await part.rename(dest.path);
    onProgress?.call(1);
  } finally {
    client.close(force: true);
  }
}

/// SHA-256 of a file, as lower-case hex.
Future<String> sha256Of(File f) async => (await crypto.sha256.bind(f.openRead()).first).toString();
