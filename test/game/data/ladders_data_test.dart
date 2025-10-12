import 'package:flutter_test/flutter_test.dart';
import 'package:snadders/game/data/ladders_data.dart';

void main() {
  final allLadders = {
    'Ladders_1': ladders_1,
    'Ladders_2': ladders_2,
    'Ladders_3': ladders_3,
    'Ladders_4': ladders_4,
    'Ladders_5': ladders_5,
    'Ladders_6': ladders_6,
    'Ladders_7': ladders_7,
    'Ladders_8': ladders_8,
  };

  final expectedEntries = {
    'Ladders_1': {6: 27, 21: 42, 32: 51, 35: 56, 60: 78, 65: 97, 69: 71, 88: 92},
    'Ladders_2': {8: 47, 16: 35, 21: 39, 41: 82, 51: 69, 65: 86},
    'Ladders_3': {7: 35, 20: 39, 31: 49, 43: 79, 54: 73, 71: 92},
    'Ladders_4': {6: 37, 19: 21, 33: 49, 60: 79, 65: 95, 72: 91},
    'Ladders_5': {10: 28, 20: 22, 37: 56, 50: 52, 59: 84, 74: 95},
    'Ladders_6': {5: 24, 30: 49, 35: 45, 40: 59, 51: 72, 57: 95, 90: 92},
    'Ladders_7': {5: 17, 22: 40, 32: 68, 37: 56, 64: 86, 80: 82, 89: 93},
    'Ladders_8': {4: 25, 13: 35, 33: 49, 50: 69, 59: 63, 62: 81, 73: 91},
  };

  final expectedLengths = {
    'Ladders_1': 8,
    'Ladders_2': 6,
    'Ladders_3': 6,
    'Ladders_4': 6,
    'Ladders_5': 6,
    'Ladders_6': 7,
    'Ladders_7': 7,
    'Ladders_8': 7,
  };

  allLadders.forEach((name, ladder) {
    test('$name should have correct entries and pass sanity checks', () {
      // Length check
      expect(ladder.length, expectedLengths[name]);

      // Specific key-value pairs
      expectedEntries[name]!.forEach((key, value) {
        expect(ladder[key], value, reason: '$name should have $key -> $value');
      });

      // Sanity checks for keys and values
      for (var entry in ladder.entries) {
        // Keys and values within 1-100
        expect(entry.key >= 1 && entry.key <= 100, true, reason: '$name key ${entry.key} out of range');
        expect(entry.value >= 1 && entry.value <= 100, true, reason: '$name value ${entry.value} out of range');

        // Key should not map to itself
        expect(entry.key != entry.value, true, reason: '$name key ${entry.key} maps to itself');

        // Ladders generally go up (value > key) — optional, apply only if applicable
        if (['Ladders_1','Ladders_2','Ladders_3','Ladders_6','Ladders_7','Ladders_8'].contains(name)) {
          expect(entry.value > entry.key, true, reason: '$name ladder value ${entry.value} should be greater than key ${entry.key}');
        }
      }

      // Check unique keys
      final keys = ladder.keys.toList();
      expect(keys.length, keys.toSet().length, reason: '$name should have unique keys');
    });
  });
}
