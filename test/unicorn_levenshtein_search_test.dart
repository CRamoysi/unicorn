import 'package:test/test.dart';
import 'package:unicorn/unicorn.dart';

void main() {
  group(r'U$levenshteinDistance', () {
    test('calcule une distance standard', () {
      expect(u$levenshteinDistance('kitten', 'sitting'), 3);
    });

    test('normalise en ignorant la casse et les espaces', () {
      expect(u$levenshteinDistance('  BONJour  ', 'bonjour'), 0);
    });

    test('early stop avec maxDistance', () {
      final distance = u$levenshteinDistance(
        'abcdefghij',
        'xyz',
        maxDistance: 2,
      );
      expect(distance, 3);
    });
  });

  group(r'U$PreparedLevenshteinIndex', () {
    test('renvoie les meilleurs matchs triés', () {
      final index = U$PreparedLevenshteinIndex<String>(
        source: const ['bonjour', 'bonsoir', 'salut', 'bonjouur'],
        valueOf: (item) => item,
      );

      final results = index.search(
        'bonjout',
        options: const U$LevenshteinSearchOptions(maxDistance: 2),
      );

      expect(results, isNotEmpty);
      expect(results.first.item, 'bonjour');
      expect(results.first.distance, 1);
      expect(results.length, 2);
      expect(results[1].item, 'bonjouur');
    });

    test('réutilise une query préparée', () {
      final index = U$PreparedLevenshteinIndex<String>(
        source: const ['alpha', 'alfa', 'omega'],
        valueOf: (item) => item,
      );

      final preparedQuery = index.prepareQuery('alfa');
      final results = index.searchPrepared(
        preparedQuery,
        options: const U$LevenshteinSearchOptions(maxDistance: 2),
      );

      expect(results.length, 2);
      expect(results.first.item, 'alfa');
      expect(results.first.distance, 0);
    });

    test('permet de matcher en mode chaîne complète', () {
      final index = U$PreparedLevenshteinIndex<String>(
        source: const ['bonjour les amis'],
        valueOf: (item) => item,
      );

      final results = index.search(
        'bonjor',
        options: const U$LevenshteinSearchOptions(
          maxDistance: 2,
          matchScope: U$LevenshteinMatchScope.chain,
        ),
      );

      expect(results, isEmpty);
    });

    test('permet de matcher en mode mots', () {
      final index = U$PreparedLevenshteinIndex<String>(
        source: const ['bonjour les amis'],
        valueOf: (item) => item,
      );

      final results = index.search(
        'bonjor',
        options: const U$LevenshteinSearchOptions(
          maxDistance: 2,
          matchScope: U$LevenshteinMatchScope.words,
        ),
      );

      expect(results, isNotEmpty);
      expect(results.first.item, 'bonjour les amis');
      expect(results.first.distance, 1);
    });

    test('permet de matcher en mode mots complexe', () {
      final index = U$PreparedLevenshteinIndex<String>(
        source: const ['CF337 Panther Repeater', 'Singe Cannon (S2)'],
        valueOf: (item) => item,
      );

      final results = index.search(
        'penth',
        options: const U$LevenshteinSearchOptions(
          maxDistance: 2,
          matchScope: U$LevenshteinMatchScope.words,
        ),
      );

      expect(results, isNotEmpty);
      expect(results.first.item, 'CF337 Panther Repeater');
      expect(results.first.distance, 1);
    });

    test('peut desactiver fuzzy en mode mots', () {
      final index = U$PreparedLevenshteinIndex<String>(
        source: const ['CF337 Panther Repeater', 'Singe Cannon (S2)'],
        valueOf: (item) => item,
      );

      final results = index.search(
        'penth',
        options: const U$LevenshteinSearchOptions(
          maxDistance: 2,
          matchScope: U$LevenshteinMatchScope.words,
          fuzzy: false,
        ),
      );

      expect(results, isEmpty);
    });

    test('fuzzy words matche un préfixe sur un mot plus long que la query', () {
      final index = U$PreparedLevenshteinIndex<String>(
        source: const ['catalog', 'cat'],
        valueOf: (item) => item,
      );

      final results = index.search(
        'cat',
        options: const U$LevenshteinSearchOptions(
          maxDistance: 1,
          matchScope: U$LevenshteinMatchScope.words,
        ),
      );

      expect(results.map((r) => r.item), containsAll(['cat', 'catalog']));
    });

    test('fuzzy words matche un préfixe avec typo sur un mot plus long', () {
      final index = U$PreparedLevenshteinIndex<String>(
        source: const ['catalog'],
        valueOf: (item) => item,
      );

      final results = index.search(
        'cataog',
        options: const U$LevenshteinSearchOptions(
          maxDistance: 1,
          matchScope: U$LevenshteinMatchScope.words,
        ),
      );

      expect(results, isNotEmpty);
      expect(results.first.item, 'catalog');
    });
  });

  group(r'u$levenshteinSimilarity', () {
    test('retourne 1.0 pour deux chaînes identiques', () {
      expect(u$levenshteinSimilarity('bonjour', 'bonjour'), 1.0);
    });

    test('retourne 0.0 pour deux chaînes sans rapport', () {
      expect(u$levenshteinSimilarity('abc', 'xyz'), 0.0);
    });

    test('retourne une valeur intermédiaire', () {
      final s = u$levenshteinSimilarity('bonjour', 'bonjor');
      expect(s, greaterThan(0.0));
      expect(s, lessThan(1.0));
    });

    test('ne dépasse pas [0..1] quand maxDistance est dépassé', () {
      final s = u$levenshteinSimilarity('abc', 'xyz', maxDistance: 1);
      expect(s, inInclusiveRange(0.0, 1.0));
      expect(s, 0.0);
    });

    test('retourne 1.0 pour deux chaînes vides', () {
      expect(u$levenshteinSimilarity('', ''), 1.0);
    });
  });
}
