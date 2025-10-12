import 'package:flutter_test/flutter_test.dart';

const List<String> boardImages = [
  'assets/images/boards/1.svg',
  'assets/images/boards/2.svg',
  'assets/images/boards/3.svg',
  'assets/images/boards/4.svg',
  'assets/images/boards/5.svg',
  'assets/images/boards/6.svg',
  'assets/images/boards/7.svg',
  'assets/images/boards/8.svg',
];
const int defaultUnlockedBoards = 3;

void main() {
  group('BOARD CONSTANTS - ', () {
    test('Correct value', () {
      expect(boardImages.length, 8);
      expect(boardImages[0], 'assets/images/boards/1.svg');
      expect(boardImages[7], 'assets/images/boards/8.svg');
      expect(defaultUnlockedBoards, 3);
    });

    // Test that the board images are not empty
    test('Using loop', () {
      final imagePattern = RegExp(r'^assets/images/boards/\d\.svg$');

      for (var image in boardImages) {
        // Check that the image is not empty
        expect(image.isNotEmpty, true);
        // Check that the image matches the pattern
        expect(imagePattern.hasMatch(image), true);
        // Check that the board images contain the word 'boards'
        expect(image.contains('boards'), true);
        // Check that the board images end with correct file extension
        expect(image.endsWith('.svg'), true);
        // Check that the board images start with the correct path
        expect(image.startsWith('assets/images/boards/'), true);
        // Check that the board images do not contain spaces
        expect(image.contains(' '), false);
      }
    });

    // Test that defaultUnlockedBoards is less than or equal to the number of board images and greater than 0
    test('Valid defaultUnlockedBoards', () {
      expect(defaultUnlockedBoards <= boardImages.length && defaultUnlockedBoards > 0, true);
    });

    // Test that all board images are unique
    test('Unique board images', () {
      expect(boardImages.length, equals(boardImages
          .toSet()
          .length));
    });

    // Test that the board images are in the correct order
    test('Correct order', () {
      for (int i = 0; i < boardImages.length; i++) {
        expect(boardImages[i], 'assets/images/boards/${i + 1}.svg');
      }
    });
  });
}