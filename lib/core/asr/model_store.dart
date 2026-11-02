import 'dart:io';

import '../download/verified_download.dart';

/// One downloadable model file, pinned by SHA-256 and size.
class ModelFile {
  const ModelFile(this.name, this.url, this.sha256, this.bytes);
  final String name;
  final Uri url;
  final String sha256;
  final int bytes;
}

/// The big speech model. It is not in the APK: it downloads once, after
/// install, and every byte is checked against the pinned SHA-256.
/// The pin and the source are the same as in tool/fetch_models.py (a test
/// keeps them equal). The small files (tokens, VAD, license) stay in the APK.
class ModelStore {
  ModelStore(this.dir, {List<ModelFile>? files}) : files = files ?? pinned;

  final Directory dir;
  final List<ModelFile> files;

  static final pinned = [
    ModelFile(
      'asr.int8.onnx',
      Uri.parse('https://huggingface.co/swaraadam/quran-phoneme-zipformer/resolve/2193d07a7d02761f6177ed12a56ecaf30658d123/model.int8.onnx'),
      '97da4c2fcaa192bfd1e0deb79f2a76cc30882dfc5f077ffa41ac9fe87f80f667',
      72705392,
    ),
  ];

  String path(String name) => '${dir.path}/$name';

  int get totalBytes => files.fold(0, (n, f) => n + f.bytes);

  /// True when every file is on the phone with the pinned size. A file is only
  /// ever renamed into place after its SHA-256 matched.
  Future<bool> isReady() async {
    for (final f in files) {
      final file = File(path(f.name));
      if (!await file.exists() || await file.length() != f.bytes) return false;
    }
    return true;
  }

  /// Downloads the missing files, one after the other. [onProgress] goes from
  /// 0 to 1 over all files. Throws on a network error (the next call resumes)
  /// or [ChecksumMismatch] (the bad file is deleted).
  Future<void> download({void Function(double progress)? onProgress}) async {
    var done = 0;
    for (final f in files) {
      final file = File(path(f.name));
      if (await file.exists() && await file.length() == f.bytes) {
        done += f.bytes;
        continue;
      }
      await downloadVerified(
        f.url,
        file,
        sha256: f.sha256,
        bytes: f.bytes,
        onProgress: (p) => onProgress?.call((done + p * f.bytes) / totalBytes),
      );
      done += f.bytes;
    }
    onProgress?.call(1);
  }
}
