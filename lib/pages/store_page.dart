import 'package:flutter/material.dart';
import 'package:snadders/pages/page_controllers/store_page_controller.dart';
import '../widgets/store/boards_tab.dart';
import '../widgets/store/coins_tab.dart';
import '../widgets/store/diamonds_tab.dart';

class StorePage extends StatefulWidget {
  final int initialTabIndex;
  const StorePage({super.key, this.initialTabIndex = 0});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StorePageController _controller = StorePageController();
  int coins = 0;
  int diamonds = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.index = widget.initialTabIndex;
    _loadResources();
  }

  void _loadResources() async {
    final loadedCoins = await _controller.loadCoins();
    final loadedDiamonds = await _controller.loadDiamonds();
    setState(() {
      coins = loadedCoins;
      diamonds = loadedDiamonds;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.brown[800],
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text(
                  'STORE',
                  style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.yellow),
                    Text(' $coins', style: const TextStyle(color: Colors.white)),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.diamond, color: Colors.blue),
                    Text(' $diamonds', style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.monetization_on, color: Colors.yellow)),
              Tab(icon: Icon(Icons.diamond, color: Colors.blue)),
              Tab(icon: Icon(Icons.phone_android)),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.yellow,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                CoinsTab(),
                DiamondsTab(),
                BoardsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
