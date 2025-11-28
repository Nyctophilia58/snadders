import 'package:flutter/material.dart';
import 'package:snadders/pages/page_controllers/store_page_controller.dart';
import 'package:snadders/services/iap_services.dart';
import '../widgets/store/boards_tab.dart';
import '../widgets/store/coins_tab.dart';
import '../widgets/store/diamonds_tab.dart';
import '../widgets/buttons/exit_button.dart';

class StorePage extends StatefulWidget {
  final IAPService iapService;
  final int initialTabIndex;
  const StorePage({super.key, this.initialTabIndex = 0, required this.iapService});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StorePageController _controller = StorePageController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.index = widget.initialTabIndex;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange, Colors.deepOrangeAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
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
                        ValueListenableBuilder<int>(
                          valueListenable: widget.iapService.coinsNotifier,
                          builder: (context, coins, _) {
                            if (!mounted) return const SizedBox();
                            return Text(' $coins', style: const TextStyle(color: Colors.white));
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.diamond, color: Colors.blue),
                        ValueListenableBuilder<int>(
                          valueListenable: widget.iapService.diamondsNotifier,
                          builder: (context, diamonds, _) {
                            if (!mounted) return const SizedBox();
                            return Text(' $diamonds', style: const TextStyle(color: Colors.white));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                color: Colors.grey[800],
                child: TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(icon: Icon(Icons.monetization_on, color: Colors.yellow)),
                    Tab(icon: Icon(Icons.diamond, color: Colors.blue)),
                    Tab(icon: Icon(Icons.phone_android, color: Colors.green)),
                  ],
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.yellow,
                ),
              ),

              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.greenAccent, Colors.blueAccent, Colors.blueGrey],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      CoinsTab(iapService: widget.iapService),
                      DiamondsTab(iapService: widget.iapService),
                      BoardsTab(iapService: widget.iapService),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Exit button at bottom-left
          Positioned(
            left: 16,
            bottom: 16,
            child: ExitButton(
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
