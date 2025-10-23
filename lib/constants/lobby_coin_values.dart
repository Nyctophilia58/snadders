class LobbyCoinValues {
  static const List<int> entryFees = [500, 1000, 2000, 5000, 10000, 25000, 50000, 100000];
  static const List<int> diamonds = [950, 1900, 3800, 4500, 9000, 22500, 45000, 90000];

  static int nextIndex(int currentIndex) {
    return (currentIndex + 1) % entryFees.length;
  }
}
