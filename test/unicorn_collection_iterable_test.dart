import 'package:test/test.dart';
import 'package:unicorn/unicorn.dart';

void main() {
	group('UnicornIterableExtension.whereNotNull', () {
		test('returns empty iterable when source is null', () {
			final Iterable<int?>? values = null;
			expect(values.whereNotNull, isEmpty);
		});

		test('filters null values and preserves order', () {
			final values = <int?>[1, null, 2, null, 3];
			expect(values.whereNotNull, [1, 2, 3]);
		});
	});

	group('UnicornListStringExtension.cleanAndTrim', () {
		test('returns empty list when source is null', () {
			final List<String>? values = null;
			expect(values.cleanAndTrim, isEmpty);
		});

		test('trims values and removes blank entries', () {
			final values = ['  a  ', ' ', '', ' b', 'c '];
			expect(values.cleanAndTrim, ['a', 'b', 'c']);
		});

		test('returns a non-growable list', () {
			final result = [' a '].cleanAndTrim;
			expect(() => result.add('b'), throwsUnsupportedError);
		});
	});

	group('UnicornMapExtension.getV', () {
		test('returns null when map is null or empty', () {
			final Map<String, dynamic>? nullMap = null;
			final emptyMap = <String, dynamic>{};

			expect(nullMap.getV<int>('a'), isNull);
			expect(emptyMap.getV<int>('a'), isNull);
		});

		test('returns value directly when already typed', () {
			final map = <String, dynamic>{'count': 12};
			expect(map.getV<int>('count'), 12);
		});

		test('parses common primitive values through tryParse', () {
			final map = <String, dynamic>{
				'asInt': '42',
				'asDouble': '3.14',
				'asBool': 'true',
			};

			expect(map.getV<int>('asInt'), 42);
			expect(map.getV<double>('asDouble'), 3.14);
			expect(map.getV<bool>('asBool'), isTrue);
		});

		test('uses custom null case for missing key', () {
			final map = <String, dynamic>{'name': 'unicorn'};

			final value = map.getV<String>(
				'missing',
				{
					Null: (_) => 'fallback-null',
				},
			);

			expect(value, 'fallback-null');
		});

		test('uses custom runtime type parser when provided', () {
			final map = <String, dynamic>{'epoch': 1700000000000};

			final value = map.getV<DateTime>(
				'epoch',
				{
					int: (raw) => DateTime.fromMillisecondsSinceEpoch(raw as int),
				},
			);

			expect(value, isA<DateTime>());
			expect(value!.millisecondsSinceEpoch, 1700000000000);
		});

		test('uses Object fallback when conversion fails', () {
			final map = <String, dynamic>{'value': 'not-a-date'};

			final value = map.getV<DateTime>(
				'value',
				{
					Object: (_) => DateTime.fromMillisecondsSinceEpoch(0),
				},
			);

			expect(value, DateTime.fromMillisecondsSinceEpoch(0));
		});
	});
}
