import 'package:flutter_test/flutter_test.dart';
import 'package:snadders/game/data/snakes_data.dart';

void main() {
  group('Test for Snakes_1 -  ', () {
    test('Snakes_1 should have 7 entries', () {
      expect(snakes_1.length, 7);
    });

    test('Snakes_1 should contain specific key-value pairs', () {
      expect(snakes_1[13], 4);
      expect(snakes_1[43], 20);
      expect(snakes_1[46], 26);
      expect(snakes_1[52], 30);
      expect(snakes_1[73], 69);
      expect(snakes_1[79], 61);
      expect(snakes_1[85], 58);
    });

    // Additional test to ensure no unexpected entries
    test('Snakes_1 should not contain unexpected entries', () {
      expect(snakes_1.containsKey(1), false);
      expect(snakes_1.containsKey(100), false);
      expect(snakes_1.containsValue(100), false);
    });
  });

  group('Test for Snakes_2 -  ', () {
    test('Snakes_2 should have 6 entries', () {
      expect(snakes_2.length, 6);
    });

    test('Snakes_2 should contain specific key-value pairs', () {
      expect(snakes_2[24], 17);
      expect(snakes_2[48], 31);
      expect(snakes_2[54], 45);
      expect(snakes_2[58], 37);
      expect(snakes_2[93], 53);
      expect(snakes_2[96], 63);
    });

    // Test for non-integer keys or values (should not exist in a Map<int, int>)
    test('Snakes_2 should not contain non-integer keys or values', () {
      expect(snakes_2.containsKey('a'), false);
      expect(snakes_2.containsValue('b'), false);
    });
  });

  group('Test for Snakes_3 -  ', () {
    test('Snakes_3 should have 7 entries', () {
      expect(snakes_3.length, 7);
    });

    test('Snakes_3 should contain specific key-value pairs', () {
      expect(snakes_3[16], 3);
      expect(snakes_3[29], 9);
      expect(snakes_3[42], 24);
      expect(snakes_3[48], 34);
      expect(snakes_3[65], 44);
      expect(snakes_3[94], 85);
      expect(snakes_3[98], 62);
    });

    // Test for negative keys or values (should not exist in a Map<int, int>)
    test('Snakes_3 should not contain negative keys or values', () {
      expect(snakes_3.containsKey(-1), false);
      expect(snakes_3.containsValue(-10), false);
    });

    // Additional test to ensure no unexpected entries
    test('Snakes_3 should not contain unexpected entries', () {
      expect(snakes_3.containsKey(0), false);
      expect(snakes_3.containsKey(100), false);
      expect(snakes_3.containsValue(100), false);
    });
  });

  group('Test for Snakes_4 -  ', () {
    test('Snakes_4 should have 6 entries', () {
      expect(snakes_4.length, 6);
    });

    test('Snakes_4 should contain specific key-value pairs', () {
      expect(snakes_4[28], 7);
      expect(snakes_4[42], 22);
      expect(snakes_4[46], 17);
      expect(snakes_4[67], 48);
      expect(snakes_4[87], 51);
      expect(snakes_4[97], 58);
    });

    // Test for duplicate values (keys must be unique in a Map)
    test('Snakes_4 should not contain duplicate keys', () {
      final keys = snakes_4.keys.toList();
      final uniqueKeys = keys.toSet().toList();
      expect(keys.length, uniqueKeys.length);
    });
  });

  group('Test for Snakes_5 -  ', () {
    test('Snakes_5 should have 7 entries', () {
      expect(snakes_5.length, 7);
    });

    test('Snakes_5 should contain specific key-value pairs', () {
      expect(snakes_5[23], 18);
      expect(snakes_5[27], 7);
      expect(snakes_5[36], 32);
      expect(snakes_5[58], 40);
      expect(snakes_5[68], 53);
      expect(snakes_5[94], 71);
      expect(snakes_5[97], 79);
    });

    // Test for keys or values out of expected range (1-100 for a typical board)
    test('Snakes_5 should have keys and values within the range 1-100', () {
      for (var key in snakes_5.keys) {
        expect(key >= 1 && key <= 100, true);
        expect(key < 1 || key > 100, false);
      }
      for (var value in snakes_5.values) {
        expect(value >= 1 && value <= 100, true);
        expect(value < 1 || value > 100, false);
      }
    });
  });

  group('Test for Snakes_6 -  ', () {
    test('Snakes_6 should have 6 entries', () {
      expect(snakes_6.length, 6);
    });

    test('Snakes_6 should contain specific key-value pairs', () {
      expect(snakes_6[28], 10);
      expect(snakes_6[39], 18);
      expect(snakes_6[54], 15);
      expect(snakes_6[63], 44);
      expect(snakes_6[93], 67);
      expect(snakes_6[98], 78);
    });

    // Test for ensuring no key maps to itself (no ladder from a square to the same square)
    test('Snakes_6 should not have any key mapping to itself', () {
      for (var entry in snakes_6.entries) {
        expect(entry.key != entry.value, true);
      }
    });
  });

  group('Test for Snakes_7 -  ', () {
    test('Snakes_7 should have 9 entries', () {
      expect(snakes_7.length, 9);
    });

    test('Snakes_7 should contain specific key-value pairs', () {
      expect(snakes_7[27], 3);
      expect(snakes_7[30], 10);
      expect(snakes_7[55], 35);
      expect(snakes_7[58], 21);
      expect(snakes_7[67], 49);
      expect(snakes_7[84], 66);
      expect(snakes_7[92], 74);
      expect(snakes_7[94], 72);
      expect(snakes_7[98], 78);
    });

    // Test for ensuring all values are greater than their corresponding keys (ladders go up)
    test('Snakes_7 should have all values less than their keys', () {
      for (var entry in snakes_7.entries) {
        expect(entry.value < entry.key, true);
      }
    });
  });

  group('Test for Snakes_8 -  ', () {
    test('Snakes_8 should have 7 entries', () {
      expect(snakes_8.length, 7);
    });

    test('Snakes_8 should contain specific key-value pairs', () {
      expect(snakes_8[27], 5);
      expect(snakes_8[40], 3);
      expect(snakes_8[43], 17);
      expect(snakes_8[54], 31);
      expect(snakes_8[66], 45);
      expect(snakes_8[95], 77);
      expect(snakes_8[99], 41);
    });
  });
}