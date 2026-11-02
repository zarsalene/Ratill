import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/core/download/verified_download.dart';

/// Real loopback HTTP server that honours Range requests.
Future<HttpServer> serve(Uint8List body, {int? dropAfter}) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  server.listen((req) async {
    final range = req.headers.value(HttpHeaders.rangeHeader);
    var from = 0;
    if (range != null) from = int.parse(RegExp(r'bytes=(\d+)-').firstMatch(range)!.group(1)!);
    req.response.statusCode = from > 0 ? HttpStatus.partialContent : HttpStatus.ok;
    req.response.contentLength = body.length - from;
    req.response.add(body.sublist(from, dropAfter != null && from == 0 ? dropAfter : body.length));
    try {
      await req.response.close();
    } catch (_) {
      // dropAfter sends less than the Content-Length on purpose.
    }
  });
  return server;
}

void main() {
  late Directory dir;
  final body = Uint8List.fromList(List.generate(300000, (i) => (i * 7 + 3) % 251));
  final good = sha256.convert(body).toString();
  setUp(() => dir = Directory.systemTemp.createTempSync('verified_download'));
  tearDown(() => dir.deleteSync(recursive: true));

  Uri url(HttpServer s) => Uri.parse('http://127.0.0.1:${s.port}/file.bin');

  test('the right hash: the file is saved, the .part file is gone', () async {
    final s = await serve(body);
    addTearDown(() => s.close(force: true));
    final dest = File('${dir.path}/file.bin');
    final progress = <double>[];
    await downloadVerified(url(s), dest, sha256: good, bytes: body.length, onProgress: progress.add);
    expect(dest.readAsBytesSync(), body);
    expect(File('${dest.path}.part').existsSync(), isFalse);
    expect(progress.last, 1.0);
  });

  test('a wrong hash: the file is deleted, nothing is renamed, the error is clear', () async {
    final s = await serve(body);
    addTearDown(() => s.close(force: true));
    final dest = File('${dir.path}/file.bin');
    final wrong = sha256.convert(utf8.encode('other')).toString();
    await expectLater(downloadVerified(url(s), dest, sha256: wrong, bytes: body.length), throwsA(isA<ChecksumMismatch>()));
    expect(dest.existsSync(), isFalse);
    expect(File('${dest.path}.part').existsSync(), isFalse);
  });

  test('a short download: the .part file is kept so the next try resumes', () async {
    final s = await serve(body, dropAfter: 100000);
    addTearDown(() => s.close(force: true));
    final dest = File('${dir.path}/file.bin');
    await expectLater(downloadVerified(url(s), dest, sha256: good, bytes: body.length), throwsA(isA<Exception>()));
    expect(dest.existsSync(), isFalse);
    expect(File('${dest.path}.part').lengthSync(), 100000);
    // Second try: the server now sends the rest on a Range request.
    await downloadVerified(url(s), dest, sha256: good, bytes: body.length);
    expect(dest.readAsBytesSync(), body);
  });

  test('a corrupt .part file from an earlier try is caught by the hash and removed', () async {
    final s = await serve(body);
    addTearDown(() => s.close(force: true));
    final dest = File('${dir.path}/file.bin');
    File('${dest.path}.part').writeAsBytesSync(List.filled(1000, 9)); // not the start of the file
    await expectLater(downloadVerified(url(s), dest, sha256: good, bytes: body.length), throwsA(isA<ChecksumMismatch>()));
    expect(File('${dest.path}.part').existsSync(), isFalse);
    // The retry starts clean and works.
    await downloadVerified(url(s), dest, sha256: good, bytes: body.length);
    expect(dest.readAsBytesSync(), body);
  });
}
