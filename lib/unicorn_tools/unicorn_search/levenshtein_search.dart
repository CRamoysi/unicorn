import 'dart:math' as math;

/// Définit la granularité du matching Levenshtein.
enum U$LevenshteinMatchScope {
  /// Compare la requête à la chaîne complète.
  chain,

  /// Compare la requête mot par mot et garde la meilleure distance.
  words,
}

/// Options de normalisation pour les recherches textuelles.
class U$LevenshteinNormalizeOptions {
  /// Configure la normalisation appliquée avant calcul.
  const U$LevenshteinNormalizeOptions({
    this.caseSensitive = false,
    this.trim = true,
    this.collapseWhitespace = true,
  });

  final bool caseSensitive;
  final bool trim;
  final bool collapseWhitespace;
}

/// Options de recherche avec index Levenshtein préparé.
class U$LevenshteinSearchOptions {
  /// Options de comportement pour [U$PreparedLevenshteinIndex.search].
  const U$LevenshteinSearchOptions({
    this.maxDistance,
    this.maxResults = 10,
    this.maxLengthDelta,
    this.matchScope = U$LevenshteinMatchScope.chain,
    this.fuzzy = true,
  });

  /// Distance maximale acceptable.
  /// Si null, aucun filtrage par distance n'est appliqué.
  final int? maxDistance;

  /// Nombre maximal de résultats renvoyés.
  final int maxResults;

  /// Ecart de taille maximal autorisé entre query et candidat.
  /// Si null, utilise [maxDistance] quand présent.
  final int? maxLengthDelta;

  /// Définit si la distance Levenshtein doit matcher sur toute la chaîne
  /// ou mot par mot.
  final U$LevenshteinMatchScope matchScope;

  /// Active les règles de matching fuzzy supplémentaires.
  final bool fuzzy;
}

/// Représente une chaîne déjà normalisée et tokenisée pour accélérer les calculs.
class U$PreparedLevenshteinTerm {
  const U$PreparedLevenshteinTerm._({
    required this.original,
    required this.normalized,
    required this.runes,
  });

  factory U$PreparedLevenshteinTerm.fromString(
    String value, {
    U$LevenshteinNormalizeOptions options =
        const U$LevenshteinNormalizeOptions(),
  }) {
    final normalized = u$normalizeForLevenshtein(value, options: options);
    return U$PreparedLevenshteinTerm._(
      original: value,
      normalized: normalized,
      runes: normalized.runes.toList(growable: false),
    );
  }

  final String original;

  /// Valeur normalisée selon [U$LevenshteinNormalizeOptions].
  final String normalized;

  /// Liste de scalaires Unicode normalisés utilisée pour les calculs.
  final List<int> runes;

  /// Longueur de la version normalisée.
  int get length => runes.length;
}

/// Résultat d'une recherche Levenshtein.
class U$LevenshteinMatch<T> {
  const U$LevenshteinMatch({
    required this.item,
    required this.value,
    required this.distance,
    required this.similarity,
  });

  final T item;

  /// Valeur brute de l'item (retournée par [valueOf] à l'indexation).
  final String value;

  /// Distance Levenshtein finale du match.
  final int distance;

  /// Similarité dans [0..1], où 1 = match parfait.
  final double similarity;
}

class _U$PreparedLevenshteinItem<T> {
  const _U$PreparedLevenshteinItem({
    required this.item,
    required this.term,
    required this.words,
  });

  final T item;
  final U$PreparedLevenshteinTerm term;
  final List<U$PreparedLevenshteinTerm> words;
}

/// Index réutilisable pour recherches Levenshtein optimisées.
class U$PreparedLevenshteinIndex<T> {
  /// Construit un index réutilisable à partir d'une source.
  ///
  /// [valueOf] extrait le texte à indexer pour chaque item métier.
  U$PreparedLevenshteinIndex({
    required Iterable<T> source,
    required String Function(T item) valueOf,
    this.normalizeOptions = const U$LevenshteinNormalizeOptions(),
  }) {
    for (final item in source) {
      final rawValue = valueOf(item);
      final term = U$PreparedLevenshteinTerm.fromString(
        rawValue,
        options: normalizeOptions,
      );
      final words = _prepareWords(term);
      final prepared =
          _U$PreparedLevenshteinItem<T>(item: item, term: term, words: words);
      _items.add(prepared);
      _itemsByLength
          .putIfAbsent(term.length, () => <_U$PreparedLevenshteinItem<T>>[])
          .add(prepared);
    }
  }

  final U$LevenshteinNormalizeOptions normalizeOptions;

  final List<_U$PreparedLevenshteinItem<T>> _items =
      <_U$PreparedLevenshteinItem<T>>[];
  final Map<int, List<_U$PreparedLevenshteinItem<T>>> _itemsByLength =
      <int, List<_U$PreparedLevenshteinItem<T>>>{};

  // Construit à la demande : inutilisé pour fuzzy=true et matchScope=chain.
  Map<int, List<_U$PreparedLevenshteinItem<T>>>? _wordLengthIndex;

  Map<int, List<_U$PreparedLevenshteinItem<T>>> _getWordLengthIndex() {
    if (_wordLengthIndex != null) return _wordLengthIndex!;
    final index = <int, List<_U$PreparedLevenshteinItem<T>>>{};
    for (final prepared in _items) {
      for (final len in prepared.words.map((w) => w.length).toSet()) {
        index.putIfAbsent(len, () => <_U$PreparedLevenshteinItem<T>>[]).add(prepared);
      }
    }
    return _wordLengthIndex = index;
  }

  /// Nombre d'éléments indexés.
  int get size => _items.length;

  /// Prépare une requête une seule fois pour réutilisation multi-recherches.
  U$PreparedLevenshteinTerm prepareQuery(String query) {
    return U$PreparedLevenshteinTerm.fromString(
      query,
      options: normalizeOptions,
    );
  }

  List<U$LevenshteinMatch<T>> search(
    String query, {
    U$LevenshteinSearchOptions options = const U$LevenshteinSearchOptions(),
  }) {
    final preparedQuery = prepareQuery(query);
    return searchPrepared(preparedQuery, options: options);
  }

  /// Recherche à partir d'une requête déjà préparée.
  ///
  /// [preparedQuery] doit être construit via [prepareQuery] pour garantir
  /// que la normalisation correspond à celle de cet index.
  /// Pratique pour les interfaces qui recalculent souvent sur les mêmes entrées.
  List<U$LevenshteinMatch<T>> searchPrepared(
    U$PreparedLevenshteinTerm preparedQuery, {
    U$LevenshteinSearchOptions options = const U$LevenshteinSearchOptions(),
  }) {
    if (_items.isEmpty || options.maxResults <= 0 || preparedQuery.length == 0) {
      return <U$LevenshteinMatch<T>>[];
    }

    final maxDistance = options.maxDistance;
    final maxLengthDelta = options.maxLengthDelta ?? maxDistance;

    final candidates = _getCandidates(
      queryLength: preparedQuery.length,
      maxLengthDelta: maxLengthDelta,
      matchScope: options.matchScope,
      fuzzy: options.fuzzy,
    );

    final matches = <U$LevenshteinMatch<T>>[];
    for (final candidate in candidates) {
      final comparison = _computeDistance(
        preparedQuery: preparedQuery,
        candidate: candidate,
        maxDistance: maxDistance,
        matchScope: options.matchScope,
        fuzzy: options.fuzzy,
      );
      final distance = comparison.distance;

      if (maxDistance != null && distance > maxDistance) {
        continue;
      }

      final maxLen = math.max(preparedQuery.length, comparison.comparedLength);
      final similarity = maxLen == 0 ? 1.0 : 1 - (distance / maxLen);

      matches.add(
        U$LevenshteinMatch<T>(
          item: candidate.item,
          value: candidate.term.original,
          distance: distance,
          similarity: similarity,
        ),
      );
    }

    matches.sort((a, b) {
      final distanceCompare = a.distance.compareTo(b.distance);
      if (distanceCompare != 0) return distanceCompare;

      final similarityCompare = b.similarity.compareTo(a.similarity);
      if (similarityCompare != 0) return similarityCompare;

      return a.value.compareTo(b.value);
    });

    if (matches.length > options.maxResults) {
      return matches.sublist(0, options.maxResults);
    }
    return matches;
  }

  Iterable<_U$PreparedLevenshteinItem<T>> _getCandidates({
    required int queryLength,
    required int? maxLengthDelta,
    required U$LevenshteinMatchScope matchScope,
    required bool fuzzy,
  }) sync* {
    if (maxLengthDelta == null) {
      yield* _items;
      return;
    }

    final minLen = math.max(0, queryLength - maxLengthDelta);
    final maxLen = queryLength + maxLengthDelta;

    if (matchScope == U$LevenshteinMatchScope.words) {
      final index = _getWordLengthIndex();
      final yielded = <_U$PreparedLevenshteinItem<T>>{};
      if (fuzzy) {
        // Pas de borne supérieure : un mot plus long peut matcher en préfixe.
        // La borne inférieure reste valide : un mot plus court que queryLength
        // ne peut pas avoir de préfixe de longueur queryLength.
        for (final entry in index.entries) {
          if (entry.key < minLen) continue;
          for (final item in entry.value) {
            if (yielded.add(item)) yield item;
          }
        }
      } else {
        for (var len = minLen; len <= maxLen; len++) {
          final bucket = index[len];
          if (bucket == null) continue;
          for (final item in bucket) {
            if (yielded.add(item)) yield item;
          }
        }
      }
      return;
    }

    for (var len = minLen; len <= maxLen; len++) {
      final bucket = _itemsByLength[len];
      if (bucket == null) continue;
      yield* bucket;
    }
  }

  List<U$PreparedLevenshteinTerm> _prepareWords(
      U$PreparedLevenshteinTerm term) {
    if (term.normalized.isEmpty) {
      return const <U$PreparedLevenshteinTerm>[];
    }

    final values =
        term.normalized.split(' ').where((word) => word.isNotEmpty).toSet();

    // Les tokens viennent de term.normalized, déjà entièrement normalisé.
    // On désactive toute re-normalisation pour éviter un double traitement.
    return values
        .map((value) => U$PreparedLevenshteinTerm.fromString(
              value,
              options: const U$LevenshteinNormalizeOptions(
                caseSensitive: true,
                trim: false,
                collapseWhitespace: false,
              ),
            ))
        .toList(growable: false);
  }

  ({int distance, int comparedLength}) _computeDistance({
    required U$PreparedLevenshteinTerm preparedQuery,
    required _U$PreparedLevenshteinItem<T> candidate,
    required int? maxDistance,
    required U$LevenshteinMatchScope matchScope,
    required bool fuzzy,
  }) {
    if (matchScope == U$LevenshteinMatchScope.chain) {
      return (
        distance: u$levenshteinDistancePrepared(
          preparedQuery.runes,
          candidate.term.runes,
          maxDistance: maxDistance,
        ),
        comparedLength: candidate.term.length,
      );
    }

    if (candidate.words.isEmpty) {
      return (
        distance: maxDistance != null ? maxDistance + 1 : preparedQuery.length,
        comparedLength: preparedQuery.length,
      );
    }

    var bestDistance = maxDistance != null ? maxDistance + 1 : 1 << 30;
    var bestLength = preparedQuery.length;

    for (final word in candidate.words) {
      var wordBestDistance = u$levenshteinDistancePrepared(
        preparedQuery.runes,
        word.runes,
        maxDistance: maxDistance,
      );
      var wordBestLength = word.length;

      // Compare la query au préfixe des mots plus longs (débuts de mots avec
      // typo). Asymétrique par conception : on cherche le début d'un mot, pas
      // l'inverse.
      if (fuzzy && word.length > preparedQuery.length) {
        final prefixDistance = _levenshteinDP(
          preparedQuery.runes, preparedQuery.length,
          word.runes, preparedQuery.length,
          maxDistance,
        );
        if (prefixDistance < wordBestDistance) {
          wordBestDistance = prefixDistance;
          wordBestLength = preparedQuery.length;
        }
      }

      if (wordBestDistance < bestDistance) {
        bestDistance = wordBestDistance;
        bestLength = wordBestLength;

        if (bestDistance == 0) {
          break;
        }
      }
    }

    return (distance: bestDistance, comparedLength: bestLength);
  }
}

/// Normalise une chaîne pour la recherche Levenshtein.
String u$normalizeForLevenshtein(
  String input, {
  U$LevenshteinNormalizeOptions options = const U$LevenshteinNormalizeOptions(),
}) {
  var result = input;
  if (options.trim) {
    result = result.trim();
  }
  if (!options.caseSensitive) {
    result = result.toLowerCase();
  }
  if (options.collapseWhitespace) {
    result = result.replaceAll(RegExp(r'\s+'), ' ');
  }
  return result;
}

/// Distance de Levenshtein classique entre deux chaînes.
///
/// Applique d'abord la normalisation définie par [options].
///
/// Si [maxDistance] est défini, l'algorithme peut s'arrêter plus tôt et
/// renvoyer `maxDistance + 1` quand la distance réelle est supérieure.
int u$levenshteinDistance(
  String a,
  String b, {
  U$LevenshteinNormalizeOptions options = const U$LevenshteinNormalizeOptions(),
  int? maxDistance,
}) {
  final preparedA = U$PreparedLevenshteinTerm.fromString(a, options: options);
  final preparedB = U$PreparedLevenshteinTerm.fromString(b, options: options);

  return u$levenshteinDistancePrepared(
    preparedA.runes,
    preparedB.runes,
    maxDistance: maxDistance,
  );
}

/// Distance de Levenshtein optimisée pour des séquences déjà préparées.
///
/// Si [maxDistance] est défini, peut renvoyer `maxDistance + 1` pour signaler
/// rapidement qu'un match dépasse le seuil sans calculer la matrice complète.
int u$levenshteinDistancePrepared(
  List<int> a,
  List<int> b, {
  int? maxDistance,
}) {
  if (identical(a, b)) return 0;
  return _levenshteinDP(a, a.length, b, b.length, maxDistance);
}

int _levenshteinDP(
  List<int> a,
  int lenA,
  List<int> b,
  int lenB,
  int? maxDistance,
) {
  if (lenA == 0) return lenB;
  if (lenB == 0) return lenA;

  final lengthDiff = (lenA - lenB).abs();
  if (maxDistance != null && lengthDiff > maxDistance) {
    return maxDistance + 1;
  }

  if (lenA > lenB) {
    return _levenshteinDP(b, lenB, a, lenA, maxDistance);
  }

  var previous = List<int>.generate(lenA + 1, (i) => i, growable: false);
  var current = List<int>.filled(lenA + 1, 0, growable: false);

  for (var j = 1; j <= lenB; j++) {
    current[0] = j;
    var rowMin = current[0];

    final codeB = b[j - 1];
    for (var i = 1; i <= lenA; i++) {
      final cost = a[i - 1] == codeB ? 0 : 1;

      final deletion = previous[i] + 1;
      final insertion = current[i - 1] + 1;
      final substitution = previous[i - 1] + cost;

      final best = math.min(math.min(deletion, insertion), substitution);
      current[i] = best;
      if (best < rowMin) {
        rowMin = best;
      }
    }

    if (maxDistance != null && rowMin > maxDistance) {
      return maxDistance + 1;
    }

    final tmp = previous;
    previous = current;
    current = tmp;
  }

  return previous[lenA];
}

/// Similarité de Levenshtein normalisée entre 0 et 1.
///
/// `1.0` signifie identité parfaite, `0.0` une forte dissimilarité.
///
/// Si [maxDistance] est défini et dépassé, retourne `0.0`.
double u$levenshteinSimilarity(
  String a,
  String b, {
  U$LevenshteinNormalizeOptions options = const U$LevenshteinNormalizeOptions(),
  int? maxDistance,
}) {
  final preparedA = U$PreparedLevenshteinTerm.fromString(a, options: options);
  final preparedB = U$PreparedLevenshteinTerm.fromString(b, options: options);

  final maxLen = math.max(preparedA.length, preparedB.length);
  if (maxLen == 0) return 1.0;

  final distance = u$levenshteinDistancePrepared(
    preparedA.runes,
    preparedB.runes,
    maxDistance: maxDistance,
  );

  if (maxDistance != null && distance > maxDistance) return 0.0;
  return 1.0 - distance / maxLen;
}
