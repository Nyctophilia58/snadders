import 'package:flutter_test/flutter_test.dart';
import 'package:snadders/game/data/ladders_data.dart';

void main() {
  group('Test for Ladders_1 -  ', () {
    test('Ladders_1 should have 8 entries', () {
      expect(ladders_1.length, 8);
    });

    test('Ladders_1 should contain specific key-value pairs', () {
      expect(ladders_1[6], 27);
      expect(ladders_1[21], 42);
      expect(ladders_1[32], 51);
      expect(ladders_1[35], 56);
      expect(ladders_1[60], 78);
      expect(ladders_1[65], 97);
      expect(ladders_1[69], 71);
      expect(ladders_1[88], 92);
    });

    // Additional test to ensure no unexpected entries
    test('Ladders_1 should not contain unexpected entries', () {
      expect(ladders_1.containsKey(1), false);
      expect(ladders_1.containsKey(100), false);
      expect(ladders_1.containsValue(100), false);
    });
  });

  group('Test for Ladders_2 -  ', () {
    test('Ladders_2 should have 6 entries', () {
      expect(ladders_2.length, 6);
    });

    test('Ladders_2 should contain specific key-value pairs', () {
      expect(ladders_2[8], 47);
      expect(ladders_2[16], 35);
      expect(ladders_2[21], 39);
      expect(ladders_2[41], 82);
      expect(ladders_2[51], 69);
      expect(ladders_2[65], 86);
    });

    // Test for non-integer keys or values (should not exist in a Map<int, int>)
    test('Ladders_2 should not contain non-integer keys or values', ()
    {
      expect(ladders_2.containsKey('a'), false);
      expect(ladders_2.containsValue('b'), false);
    });
  });

  group('Test for Ladders_3 -  ', () {
    test('Ladders_3 should have 6 entries', () {
      expect(ladders_3.length, 6);
    });

    test('Ladders_3 should contain specific key-value pairs', () {
      expect(ladders_3[7], 35);
      expect(ladders_3[20], 39);
      expect(ladders_3[31], 49);
      expect(ladders_3[43], 79);
      expect(ladders_3[54], 73);
      expect(ladders_3[71], 92);
    });

    // Test for negative keys or values (should not exist in a Map<int, int>)
    test('Ladders_3 should not contain negative keys or values', () {
      expect(ladders_3.containsKey(-1), false);
      expect(ladders_3.containsValue(-10), false);
    });
  });

  group('Test for Ladders_4 -  ', () {
    test('Ladders_4 should have 6 entries', () {
      expect(ladders_4.length, 6);
    });

    test('Ladders_4 should contain specific key-value pairs', () {
      expect(ladders_4[6], 37);
      expect(ladders_4[19], 21);
      expect(ladders_4[33], 49);
      expect(ladders_4[60], 79);
      expect(ladders_4[65], 95);
      expect(ladders_4[72], 91);
    });

    // Test for duplicate values (keys must be unique in a Map)
    test('Ladders_4 should not contain duplicate keys', () {
      final keys = ladders_4.keys.toList();
      final uniqueKeys = keys.toSet().toList();
      expect(keys.length, uniqueKeys.length);
    });
  });

  group('Test for Ladders_5 -  ', () {
    test('Ladders_5 should have 6 entries', () {
      expect(ladders_5.length, 6);
    });

    test('Ladders_5 should contain specific key-value pairs', () {
      expect(ladders_5[10], 28);
      expect(ladders_5[20], 22);
      expect(ladders_5[37], 56);
      expect(ladders_5[50], 52);
      expect(ladders_5[59], 84);
      expect(ladders_5[74], 95);
    });

    // Test for keys or values out of expected range (1-100 for a typical board)
    test('Ladders_5 should have keys and values within the range 1-100', () {
      for (var key in ladders_5.keys) {
        expect(key >= 1 && key <= 100, true);
        expect(key < 1 || key > 100, false);
      }
      for (var value in ladders_5.values) {
        expect(value >= 1 && value <= 100, true);
        expect(value < 1 || value > 100, false);
      }
    });
  });

  group('Test for Ladders_6 -  ', () {
    test('Ladders_6 should have 7 entries', () {
      expect(ladders_6.length, 7);
    });

    test('Ladders_6 should contain specific key-value pairs', () {
      expect(ladders_6[5], 24);
      expect(ladders_6[30], 49);
      expect(ladders_6[35], 45);
      expect(ladders_6[40], 59);
      expect(ladders_6[51], 72);
      expect(ladders_6[57], 95);
      expect(ladders_6[90], 92);
    });

    // Test for ensuring no key maps to itself (no ladder from a square to the same square)
    test('Ladders_6 should not have any key mapping to itself', () {
      for (var entry in ladders_6.entries) {
        expect(entry.key != entry.value, true);
      }
    });
  });

  group('Test for Ladders_7 -  ', () {
    test('Ladders_7 should have 7 entries', () {
      expect(ladders_7.length, 7);
    });

    test('Ladders_7 should contain specific key-value pairs', () {
      expect(ladders_7[5], 17);
      expect(ladders_7[22], 40);
      expect(ladders_7[32], 68);
      expect(ladders_7[37], 56);
      expect(ladders_7[64], 86);
      expect(ladders_7[80], 82);
      expect(ladders_7[89], 93);
    });

    // Test for ensuring all values are greater than their corresponding keys (ladders go up)
    test('Ladders_7 should have all values greater than their keys', () {
      for (var entry in ladders_7.entries) {
        expect(entry.value > entry.key, true);
      }
    });
  });

  group('Test for Ladders_8 -  ', () {
    test('Ladders_8 should have 7 entries', () {
      expect(ladders_8.length, 7);
    });

    test('Ladders_8 should contain specific key-value pairs', () {
      expect(ladders_8[4], 25);
      expect(ladders_8[13], 35);
      expect(ladders_8[33], 49);
      expect(ladders_8[50], 69);
      expect(ladders_8[59], 63);
      expect(ladders_8[62], 81);
      expect(ladders_8[73], 91);
    });
  });
}