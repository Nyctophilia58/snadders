import 'package:flutter_test/flutter_test.dart';
import 'package:snadders/game/data/snakes_data.dart';

void main() {
  final allSnakes = {
    'Snakes_1': snakes_1,
    'Snakes_2': snakes_2,
    'Snakes_3': snakes_3,
    'Snakes_4': snakes_4,
    'Snakes_5': snakes_5,
    'Snakes_6': snakes_6,
    'Snakes_7': snakes_7,
    'Snakes_8': snakes_8,
  };

  final expectedEntries = {
    'Snakes_1': {13: 4, 43: 20, 46: 26, 52: 30, 73: 69, 79: 61, 85: 58},
    'Snakes_2': {24: 17, 48: 31, 54: 45, 58: 37, 93: 53, 96: 63},
    'Snakes_3': {16: 3, 29: 9, 42: 24, 48: 34, 65: 44, 94: 85, 98: 62},
    'Snakes_4': {28: 7, 42: 22, 46: 17, 67: 48, 87: 51, 97: 58},
    'Snakes_5': {23: 18, 27: 7, 36: 32, 58: 40, 68: 53, 94: 71, 97: 79},
    'Snakes_6': {28: 10, 39: 18, 54: 15, 63: 44, 93: 67, 98: 78},
    'Snakes_7': {27: 3, 30: 10, 55: 35, 58: 21, 67: 49, 84: 66, 92: 74, 94: 72, 98: 78},
    'Snakes_8': {27: 5, 40: 3, 43: 17, 54: 31, 66: 45, 95: 77, 99: 41},
  };

  final expectedLengths = {
    'Snakes_1': 7,
    'Snakes_2': 6,
    'Snakes_3': 7,
    'Snakes_4': 6,
    'Snakes_5': 7,
    'Snakes_6': 6,
    'Snakes_7': 9,
    'Snakes_8': 7,
  };

  allSnakes.forEach((name, snake) {
    test('$name should have correct entries and pass sanity checks', () {
      // Length check
      expect(snake.length, expectedLengths[name]);

      // Specific key-value pairs
      expectedEntries[name]!.forEach((key, value) {
        expect(snake[key], value, reason: '$name should have $key -> $value');
      });

      // Sanity checks
      for (var entry in snake.entries) {
        // Keys and values within 1-100
        expect(entry.key >= 1 && entry.key <= 100, true, reason: '$name key ${entry.key} out of range');
        expect(entry.value >= 1 && entry.value <= 100, true, reason: '$name value ${entry.value} out of range');

        // Key should not map to itself
        expect(entry.key != entry.value, true, reason: '$name key ${entry.key} maps to itself');

        // Snakes go down (value < key)
        expect(entry.value < entry.key, true, reason: '$name snake value ${entry.value} should be less than key ${entry.key}');
      }

      // Check unique keys
      final keys = snake.keys.toList();
      expect(keys.length, keys.toSet().length, reason: '$name should have unique keys');
    });
  });
}
