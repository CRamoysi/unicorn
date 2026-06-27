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

- **Lookup, parse, recherche sans match** : retour souple (`null`, liste vide).
- **Violation de contrat** (argument invalide, mauvais etat d'une API stateful) :
  `throw` (`ArgumentError`, `StateError`).

Les modules futurs suivent cette meme logique selon la nature de l'API.

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
