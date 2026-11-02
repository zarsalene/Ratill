import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/core/asr/model_store.dart';
import 'package:rattil/core/download/verified_download.dart';

void main() {
  test('the pins in the app equal the pins in tool/fetch_models.py', () {
    final py = File('tool/fetch_models.py').readAsStringSync();
    final sums = {
      for (final m in RegExp(r'\("([\w.]+)", [^,]+, "([0-9a-f]{64})"\)').allMatches(py)) m.group(1)!: m.group(2)!,
    };
    expect(ModelStore.pinned, isNotEmpty);
    for (final f in ModelStore.pinned) {
      expect(f.sha256, sums[f.name], reason: f.name);
      expect(py, contains(f.url.toString().replaceFirst('/model.int8.onnx', '')), reason: '${f.name} source');
    }
  });

  test('every pinned file is on https', () {
    for (final f in ModelStore.pinned) {
      expect(f.url.scheme, 'https', reason: f.name);
    }
  });

  group('with a local server', () {
    late Directory dir;
    late HttpServer server;
    final a = List.generate(5000, (i) => i % 200);
    final b = List.generate(300, (i) => (i * 3) % 200);
    setUp(() async {
      dir = Directory.systemTemp.createTempSync('model_store');
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((req) async {
        final body = req.uri.path == '/a' ? a : b;
        req.response.add(body);
        await req.response.close();
      });
    });
    tearDown(() async {
      await server.close(force: true);
      dir.deleteSync(recursive: true);
    });

    ModelFile file(String name, List<int> body, {String? sum}) => ModelFile(
          name,
          Uri.parse('http://127.0.0.1:${server.port}/${name == 'a.bin' ? 'a' : 'b'}'),
          sum ?? sha256.convert(body).toString(),
          body.length,
        );

    test('not ready until every file is downloaded and checked', () async {
      final store = ModelStore(dir, files: [file('a.bin', a), file('b.bin', b)]);
      expect(await store.isReady(), isFalse);
      final progress = <double>[];
      await store.download(onProgress: progress.add);
      expect(await store.isReady(), isTrue);
      expect(File(store.path('a.bin')).readAsBytesSync(), a);
      expect(progress.last, 1.0);
      expect(progress, orderedEquals([...progress]..sort()), reason: 'progress never goes back');
    });

    test('a file with the wrong size is not ready', () async {
      final store = ModelStore(dir, files: [file('a.bin', a)]);
      await store.download();
      File(store.path('a.bin')).writeAsBytesSync([1, 2, 3]);
      expect(await store.isReady(), isFalse);
    });

    test('a file that fails its hash stops the download and is not kept', () async {
      final store = ModelStore(dir, files: [file('a.bin', a, sum: '0' * 64)]);
      await expectLater(store.download(), throwsA(isA<ChecksumMismatch>()));
      expect(await store.isReady(), isFalse);
      expect(File(store.path('a.bin')).existsSync(), isFalse);
    });
  });
}
