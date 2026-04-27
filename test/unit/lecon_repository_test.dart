import 'package:flutter_driveauto_app/data/repositories/lecon_repository.dart';
import 'package:flutter_driveauto_app/domain/models/lecon.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FakeLeconBox implements Box<Lecon> {
  final Map<dynamic, Lecon> _store = <dynamic, Lecon>{};

  @override
  Iterable<Lecon> get values => _store.values;

  @override
  Future<int> clear() async {
    final previousLength = _store.length;
    _store.clear();
    return previousLength;
  }

  @override
  Future<void> put(key, Lecon value) async {
    _store[key] = value;
  }

  @override
  Future<void> delete(key) async {
    _store.remove(key);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late LeconRepository repository;
  late FakeLeconBox fakeBox;

  setUp(() {
    fakeBox = FakeLeconBox();
    repository = LeconRepository(firestore: null, box: fakeBox);
  });

  group('LeconRepository Tests', () {
    test('getLecons() retourne une liste de secours si aucun cache', () async {
      final lecons = await repository.getLecons();

      expect(lecons, isA<List<Lecon>>());
      expect(lecons, isNotEmpty);
    });

    test('cache Hive hit -> pas d appel reseau necessaire', () async {
      final fakeLecon = Lecon(
        id: '1',
        titre: 'Test',
        texteRiche: 'Texte',
        categorie: 'Auto',
      );
      await fakeBox.put(fakeLecon.id, fakeLecon);

      final lecons = await repository.getLecons();

      expect(lecons.length, 1);
      expect(lecons.first.titre, 'Test');
    });
  });
}
