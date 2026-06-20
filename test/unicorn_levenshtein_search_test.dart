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
  });
}
