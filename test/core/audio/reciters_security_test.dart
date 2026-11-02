import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/core/audio/audio_catalog.dart';

void main() {
  group('S3: the audio server from the web API', () {
    test('http becomes https, a trailing slash is added', () {
      expect(Reciter.safeServer('http://server7.mp3quran.net/shatri'), 'https://server7.mp3quran.net/shatri/');
      expect(Reciter.safeServer('https://server7.mp3quran.net/shatri/'), 'https://server7.mp3quran.net/shatri/');
      expect(Reciter.safeServer('https://mp3quran.net/x/'), 'https://mp3quran.net/x/');
    });

    test('other schemes are rejected', () {
      for (final u in ['ftp://server7.mp3quran.net/x/', 'file:///data/x/', 'javascript:alert(1)', 'content://x/y', '//server7.mp3quran.net/x/']) {
        expect(Reciter.safeServer(u), isNull, reason: u);
      }
    });

    test('only known hosts: mp3quran.net and its subdomains', () {
      expect(Reciter.safeServer('https://evil.example/x/'), isNull);
      expect(Reciter.safeServer('https://mp3quran.net.evil.example/x/'), isNull);
      expect(Reciter.safeServer('https://evilmp3quran.net/x/'), isNull);
      expect(Reciter.safeServer('https://mp3quran.net@evil.example/x/'), isNull);
    });

    test('nothing and garbage are rejected', () {
      expect(Reciter.safeServer(null), isNull);
      expect(Reciter.safeServer(''), isNull);
      expect(Reciter.safeServer('not a url'), isNull);
    });
  });

  group('S4: a reciter id saved on the phone', () {
    Map<String, Object?> json(String id) => {'id': id, 'name': 'x', 'riwaya': 'hafs'};

    test('letters, digits and underscore are fine', () {
      expect(Reciter.fromJson(json('mp3q_12')).id, 'mp3q_12');
      expect(Reciter.fromJson(json('husary_muallim')).id, 'husary_muallim');
    });

    test('a path in the id is rejected', () {
      for (final id in ['../x', 'a/b', r'a\b', '', 'mp3q_1/..']) {
        expect(() => Reciter.fromJson(json(id)), throwsFormatException, reason: id);
      }
    });
  });

  group('S4: the reciter id from the web API builds a storage folder name', () {
    test('an integer gives mp3q_<n>', () {
      expect(Reciter.apiId(12), 'mp3q_12');
    });

    test('anything else throws, so the row is skipped', () {
      expect(() => Reciter.apiId('../x'), throwsA(isA<TypeError>()));
      expect(() => Reciter.apiId('12'), throwsA(isA<TypeError>()));
      expect(() => Reciter.apiId(null), throwsA(isA<TypeError>()));
      expect(() => Reciter.apiId(1.5), throwsA(isA<TypeError>()));
    });
  });
}
