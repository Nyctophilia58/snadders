import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/board_constants.dart';
import '../pages/store_page.dart';
import '../services/iap_services.dart';
import 'controllers/board_selector_controller.dart';

class BoardSelector extends StatefulWidget {
  final IAPService iapService;
  const BoardSelector({super.key, required this.iapService});

  @override
  State<BoardSelector> createState() => _BoardSelectorState();
}

class _BoardSelectorState extends State<BoardSelector> {
  final BoardSelectorController _controller = BoardSelectorController();
  List<bool> unlockedBoards = [];

  @override
  void initState() {
    super.initState();
    _loadUnlockedBoards();
  }

  Future<void> _loadUnlockedBoards() async {
    final boards = await _controller.loadUnlockedBoards();
    setState(() => unlockedBoards = boards);
  }

  @override
  Widget build(BuildContext context) {
    if (unlockedBoards.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final isUnlocked = unlockedBoards[_controller.currentBoardIndex];

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        height: 600,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: _buildBoardPreview(isUnlocked)),
            _buildNavigation(),
            _buildActionButton(context, isUnlocked),
          ],
        ),
      ),
    );
  }

  Widget _buildBoardPreview(bool isUnlocked) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            boardImages[_controller.currentBoardIndex],
            fit: BoxFit.contain,
            width: 360,
            height: 500,
          ),
          if (!isUnlocked)
            FittedBox(
              fit: BoxFit.contain,
              child: Container(
                width: 360,
                height: 500,
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: Icon(Icons.lock, color: Colors.white, size: 80),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_left, size: 40),
          onPressed: () => setState(() => _controller.prevBoard()),
        ),
        Text(
          'Board ${_controller.currentBoardIndex + 1}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_right, size: 40),
          onPressed: () => setState(() => _controller.nextBoard()),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, bool isUnlocked) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        if (isUnlocked) {
          Navigator.pop(context, _controller.currentBoardIndex);
        } else {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StorePage(initialTabIndex: 2, iapService: widget.iapService,),
            ),
          );
        }
      },
      child: Text(
        isUnlocked ? 'Select' : 'Buy',
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}
