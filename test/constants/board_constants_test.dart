import 'package:flutter_test/flutter_test.dart';

void main() {
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

  group('BOARD CONSTANTS - ', () {
    test('Correct values', () {
      expect(boardImages.length, 8);
      expect(boardImages.first, 'assets/images/boards/1.svg');
      expect(boardImages.last, 'assets/images/boards/8.svg');
      expect(defaultUnlockedBoards, 3);
    });

    test('All board images are valid', () {
      final pattern = RegExp(r'^assets/images/boards/\d\.svg$');

      for (var image in boardImages) {
        expect(image.isNotEmpty, true, reason: 'Image path should not be empty');
        expect(pattern.hasMatch(image), true, reason: 'Invalid image path format: $image');
        expect(image.contains(' '), false, reason: 'Image path should not contain spaces: $image');
      }
    });

    test('defaultUnlockedBoards is valid', () {
      expect(defaultUnlockedBoards > 0 && defaultUnlockedBoards <= boardImages.length, true);
    });

    test('All board images are unique', () {
      expect(boardImages.length, boardImages.toSet().length);
    });

    test('Board images are in correct order', () {
      for (int i = 0; i < boardImages.length; i++) {
        expect(boardImages[i], 'assets/images/boards/${i + 1}.svg');
      }
    });
  });
}
