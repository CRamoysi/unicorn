# unicorn

Toolkit Dart/Flutter modulaire avec utilitaires de types, collections, logs et
recherche textuelle Levenshtein optimisee.

## Installation

Ajoutez le package dans votre `pubspec.yaml` puis:

```bash
flutter pub get
```

## Import principal

```dart
import 'package:unicorn/unicorn.dart';
```

L'import principal expose:

- `unicorn_core.dart`
- `unicorn_logger.dart`
- `unicorn_clock.dart`
- `unicorn_collection.dart`
- `unicorn_type.dart`
- `unicorn_tools/unicorn_search/levenshtein_search.dart`

## Convention de gestion des erreurs

Le toolkit distingue deux cas :

- **Lookup, tryParse, recherche sans match** : retour souple (`null`, liste vide).
- **Parse strict** : conversion invalide signalée par une `FormatException`.
- **Violation de contrat** (argument invalide, mauvais etat d'une API stateful) :
  `throw` (`ArgumentError`, `StateError`).

Les modules futurs suivent cette meme logique selon la nature de l'API.

## Typage et parsing

Les extensions de typage sont exportees par `package:unicorn/unicorn.dart`.
Le point d'entree generique est `tryParse<T>()` :

```dart
final count = '42'.tryParse<int>();
final enabled = 'true'.tryParse<bool>();
final date = '2024-01-01'.tryParse<DateTime>();
final values = rawValues.tryParseList<int>();
```

Les types natifs pris en charge sont :

| Type cible | Regle de conversion |
|------------|---------------------|
| `int` | Entier, nombre tronque, ou chaîne numérique |
| `double` | Nombre décimal, ou chaîne numérique |
| `String` | Conversion via `toString()` |
| `DateTime` | Instance existante ou chaîne ISO-8601 |
| `bool` | `true`, `1`, `"true"` et `"1"` donnent `true`; `false`, `0`, `"false"` et `"0"` donnent `false`; une valeur invalide donne `null` |

Chaque type dispose également d'un parseur statique :

```dart
U$Int.tryParse('42');
U$Double.tryParse('3.14');
U$String.tryParse(42);
U$List.tryParse<String>([' a ', '', 'b']);
U$DateTime.tryParse('2024-01-01');
U$Bool.tryParse('true');
U$Bool.parse('valeur-invalide'); // lève FormatException
```

`U$List.tryParse<T>()` parse chaque élément vers `T` et ignore les éléments
nulls ou impossibles à convertir. L'extension `tryParseList<T>()` permet de
l'utiliser directement sur une valeur :

```dart
final values = rawValues.tryParseList<int>();
```

Le parsing ne trim pas automatiquement les chaînes ; utilisez `cleanAndTrim`
pour ce besoin.

Les méthodes `parse` sont strictes et lèvent une `FormatException` si la
conversion échoue. Les méthodes `tryParse` sont tolérantes et retournent
`null`.

Pour les booléens, `U$Bool.tryParse()` retourne `null` si la valeur est
invalide. `U$Bool.parse()` applique la même conversion et lève une
`FormatException` dans ce cas.

Pour les types non natifs, utilisez `customCases`. La clé peut être le type
runtime exact de la valeur source, `Null` pour une valeur absente ou `Object`
comme fallback final :

Un `customCase` associé au type runtime exact est prioritaire, y compris si la
valeur est déjà du type cible. Il peut donc surcharger un parseur natif.

```dart
final value = raw.tryParse<MyType>(
  customCases: {
    String: (raw) => MyType.fromString(raw as String),
    Object: (_) => MyType.defaultValue(),
  },
);
```

## Chrono (U$Clock)

`U$Clock` est un singleton leger pour mesurer des durees nommees.

### API disponible

- `U$Clock().start(name, {reset = true})`
- `U$Clock().stop(name)`
- `U$Clock().getDuration(name)`
- `U$Clock().show(name)`

### Exemple rapide

```dart
final clock = U$Clock();

clock.start('import-job');
// ... votre traitement ...
clock.stop('import-job');

final elapsed = clock.getDuration('import-job');
print('Temps ecoule: $elapsed');
```

### Comportement important

- Chaque `start(name)` demarre une nouvelle mesure pour ce nom (remplace l'instance precedente).
- `reset: true` (defaut) supprime d'abord l'etat existant du nom avant de demarrer.
- `start(name, reset: false)` leve une erreur si le chrono tourne deja.
- `stop(name)` leve une erreur si le chrono n'est pas en cours.
- `getDuration(name)` et `show(name)` levent une erreur si le chrono tourne encore
  ou si le nom est inconnu.

`U$Clock` applique la convention **violation de contrat** : une mauvaise sequence
(`start` → `stop` → lecture) leve un `StateError` plutot que de renvoyer une
duree silencieusement fausse.

### Erreurs (`StateError`)

| Situation | Message (extrait) |
|-----------|-------------------|
| `start(name, reset: false)` alors que le chrono tourne | `already running` |
| `stop(name)` sans chrono en cours | `not running` |
| `getDuration` / `show` pendant l'execution | `still running` |
| `getDuration` / `show` sur un nom inconnu | `not found` |

En usage normal, enchainer `start` → `stop` → `getDuration` ou `show` ; aucun
`try/catch` n'est necessaire.

## Recherche Levenshtein

Les API de recherche sont dans
`lib/unicorn_tools/unicorn_search/levenshtein_search.dart` et exportees via
`package:unicorn/unicorn.dart`.

### API publique disponible

- `enum U$LevenshteinMatchScope`
- `class U$LevenshteinNormalizeOptions`
- `class U$LevenshteinSearchOptions`
- `class U$PreparedLevenshteinTerm`
- `class U$LevenshteinMatch<T>`
- `class U$PreparedLevenshteinIndex<T>`
- `String u$normalizeForLevenshtein(...)`
- `int u$levenshteinDistance(...)`
- `int u$levenshteinDistancePrepared(...)`
- `double u$levenshteinSimilarity(...)`

### 1) Calcul simple de distance

```dart
final d = u$levenshteinDistance('kitten', 'sitting');
// d == 3
```

### 2) Similarite normalisee

```dart
final s = u$levenshteinSimilarity('bonjour', 'bonjor');
// s proche de 0.86
```

### 3) Index prepare reutilisable

```dart
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

if (results.isNotEmpty) {
	final best = results.first;
	// best.item, best.distance, best.similarity
}
```

### 4) Requete preparee (optimisation UI)

```dart
final prepared = index.prepareQuery('panther');

final pass1 = index.searchPrepared(
	prepared,
	options: const U$LevenshteinSearchOptions(maxDistance: 2),
);

final pass2 = index.searchPrepared(
	prepared,
	options: const U$LevenshteinSearchOptions(
		maxDistance: 1,
		matchScope: U$LevenshteinMatchScope.words,
	),
);
```

## Options de recherche

`U$LevenshteinSearchOptions`:

- `maxDistance`: seuil de distance maximal. Si depasse, le match est ignore.
- `maxResults`: limite de resultats retournes (defaut: `10`).
- `maxLengthDelta`: filtre rapide sur l'ecart de taille candidat/requete.
	`null` signifie aucun filtre explicite (ou fallback sur `maxDistance`).
- `matchScope`:
	- `U$LevenshteinMatchScope.chain`: compare la chaine complete.
	- `U$LevenshteinMatchScope.words`: compare mot par mot.
- `fuzzy` (defaut `true`): active des regles fuzzy supplementaires en mode
	`words` (notamment les matchs de debut de mot avec typo).

## Options de normalisation

`U$LevenshteinNormalizeOptions`:

- `caseSensitive` (defaut `false`): ignore ou non la casse.
- `trim` (defaut `true`): supprime les espaces en bord.
- `collapseWhitespace` (defaut `true`): remplace les espaces multiples par un.

Exemple:

```dart
final d = u$levenshteinDistance(
	'  BONJour  ',
	'bonjour',
	options: const U$LevenshteinNormalizeOptions(
		caseSensitive: false,
		trim: true,
		collapseWhitespace: true,
	),
);
// d == 0
```

## Notes de performance

- Utilisez `U$PreparedLevenshteinIndex` des que la meme liste est interrogee
	plusieurs fois.
- Utilisez `prepareQuery` + `searchPrepared` si la requete est reutilisee.
- Renseignez `maxDistance` pour beneficier d'un early-stop.
- Renseignez `maxLengthDelta` pour reduire les candidats examines.

## Tests

Executer la suite de tests:

```bash
flutter test
```
