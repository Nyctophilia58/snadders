import 'package:flutter/material.dart';
import '../services/shared_prefs_service.dart';
import '../widgets/store/boards_tab.dart';
import '../widgets/store/coins_tab.dart';
import '../widgets/store/diamonds_tab.dart';
import '../widgets/store/offers_tab.dart';

class StorePage extends StatefulWidget {
  final int initialTabIndex;
  const StorePage({super.key, this.initialTabIndex = 0});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SharedPrefsService _sharedPrefsService = SharedPrefsService();
  int coins = 0;
  int diamonds = 0;

  @override
  void initState() {
    super.initState();
    _loadCoins();
    _loadDiamonds();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.index = widget.initialTabIndex;
  }

  Future<void> _loadCoins() async {
    final loadedCoins = await _sharedPrefsService.loadCoins();
    setState(() {
      coins = loadedCoins;
    });
  }

  Future<void> _loadDiamonds() async {
    final loadedDiamonds = await _sharedPrefsService.loadDiamonds();
    setState(() {
      diamonds = loadedDiamonds;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image or color
          // Container(
          //   decoration: BoxDecoration(
          //     image: DecorationImage(
          //       image: AssetImage(''),
          //       fit: BoxFit.cover,
          //     ),
          //     color: Colors.red[900],
          //   ),
          // ),
          Column(
            children: [
              Container(
                color: Colors.brown[800],
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('STORE', style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Icon(Icons.monetization_on, color: Colors.yellow),
                        Text(
                          ' $coins',
                          style: TextStyle(color: Colors.white)
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.diamond, color: Colors.blue),
                        Text(
                          ' $diamonds',
                          style: TextStyle(color: Colors.white)
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              //
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(icon: Icon(Icons.monetization_on, color: Colors.yellow)),
                  Tab(icon: Icon(Icons.diamond, color: Colors.blue)),
                  Tab(icon: Icon(Icons.phone_android)),
                  Tab(icon: Icon(Icons.local_offer, color: Colors.red)),
                ],
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.yellow,
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    CoinsTab(),
                    DiamondsTab(),
                    BoardsTab(),
                    OffersTab(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}