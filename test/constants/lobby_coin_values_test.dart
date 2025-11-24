import 'package:flutter_test/flutter_test.dart';
import 'package:snadders/constants/lobby_coin_values.dart';

void main() {
  group('LobbyCoinValues - ', () {
    test('nextIndex returns the next index correctly', () {
      expect(LobbyCoinValues.nextIndex(0), 1);
      expect(LobbyCoinValues.nextIndex(3), 4);
      expect(LobbyCoinValues.nextIndex(6), 7);

      expect(LobbyCoinValues.nextIndex(7), 0);
    });

    test('entryFees and diamonds lists have the same length', () {
      expect(LobbyCoinValues.entryFees.length, LobbyCoinValues.winValues.length);
    });

    test('entryFees and diamonds lists are not empty', () {
      expect(LobbyCoinValues.entryFees.isNotEmpty, true);
      expect(LobbyCoinValues.winValues.isNotEmpty, true);
    });

    test('entryFees and diamonds lists contain positive values', () {
      for (var fee in LobbyCoinValues.entryFees) {
        expect(fee > 0, true);
      }
      for (var diamond in LobbyCoinValues.winValues) {
        expect(diamond > 0, true);
      }
    });

    test('entryFees and diamonds lists have unique values', () {
      expect(LobbyCoinValues.entryFees.length, LobbyCoinValues.entryFees.toSet().length);
      expect(LobbyCoinValues.winValues.length, LobbyCoinValues.winValues.toSet().length);
    });
  });
}
