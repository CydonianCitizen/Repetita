import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/features/cards/data/cards_dao.dart';
import 'package:repetita/src/features/decks/data/decks_dao.dart';
import 'package:repetita/src/features/tags/data/tags_dao.dart';

void main() {
  late AppDatabase db;
  late DecksDao decksDao;
  late CardsDao cardsDao;
  late TagsDao tagsDao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    decksDao = DecksDao(db);
    cardsDao = CardsDao(db);
    tagsDao = TagsDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('TagsDao Unit Tests', () {
    test('getOrCreateTag creates tag or returns existing tag ID', () async {
      final tagId1 = await tagsDao.getOrCreateTag('Grammar', color: 0xFF123456);
      expect(tagId1, isPositive);

      final tagId2 = await tagsDao.getOrCreateTag('Grammar');
      expect(tagId2, equals(tagId1));

      final tagId3 = await tagsDao.getOrCreateTag('Vocab');
      expect(tagId3, isNot(equals(tagId1)));

      final allTags = await tagsDao.getAllTags();
      expect(allTags, hasLength(2));
      expect(allTags.map((t) => t.name), containsAll(['Grammar', 'Vocab']));
    });

    test('associates and retrieves tags for a card', () async {
      final deckId = await decksDao.createDeck(name: 'Latin');
      final cardId = await cardsDao.createCard(
        deckId: deckId,
        front: 'Amor',
        back: 'Love',
      );

      final tag1 = await tagsDao.getOrCreateTag('Nouns');
      final tag2 = await tagsDao.getOrCreateTag('Declension 3');

      await tagsDao.setCardTags(cardId, [tag1, tag2]);

      final cardTags = await tagsDao.getTagsForCard(cardId);
      expect(cardTags, hasLength(2));
      expect(cardTags.map((t) => t.id), containsAll([tag1, tag2]));

      // Update tags
      await tagsDao.setCardTags(cardId, [tag1]);
      final updatedTags = await tagsDao.getTagsForCard(cardId);
      expect(updatedTags, hasLength(1));
      expect(updatedTags.first.id, equals(tag1));
    });

    test('watchTagsForDeck groups tags by card ID', () async {
      final deckId = await decksDao.createDeck(name: 'Biology');
      final card1 = await cardsDao.createCard(
        deckId: deckId,
        front: 'Cell',
        back: 'Unit of life',
      );
      final card2 = await cardsDao.createCard(
        deckId: deckId,
        front: 'DNA',
        back: 'Genetic code',
      );

      final tagBio = await tagsDao.getOrCreateTag('General Bio');
      final tagGenetics = await tagsDao.getOrCreateTag('Genetics');

      await tagsDao.setCardTags(card1, [tagBio]);
      await tagsDao.setCardTags(card2, [tagBio, tagGenetics]);

      final deckTagsMap = await tagsDao.watchTagsForDeck(deckId).first;
      expect(deckTagsMap[card1], hasLength(1));
      expect(deckTagsMap[card1]!.first.name, equals('General Bio'));
      expect(deckTagsMap[card2], hasLength(2));
    });

    test('deleting a tag cascades and removes card association', () async {
      final deckId = await decksDao.createDeck(name: 'History');
      final cardId = await cardsDao.createCard(
        deckId: deckId,
        front: '1789',
        back: 'French Revolution',
      );

      final tagId = await tagsDao.getOrCreateTag('18th Century');
      await tagsDao.setCardTags(cardId, [tagId]);

      expect(await tagsDao.getTagsForCard(cardId), hasLength(1));

      await tagsDao.deleteTag(tagId);

      expect(await tagsDao.getTagsForCard(cardId), isEmpty);
      expect(await tagsDao.getAllTags(), isEmpty);
    });
  });
}
