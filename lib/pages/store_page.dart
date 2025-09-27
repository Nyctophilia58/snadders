import 'package:flutter/material.dart';
import '../widgets/offers/boards_tab.dart';
import '../widgets/offers/coins_tab.dart';
import '../widgets/offers/diamonds_tab.dart';
import '../widgets/offers/offers_tab.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
                        Text(' 1,100', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.diamond, color: Colors.blue),
                        Text(' 125', style: TextStyle(color: Colors.white)),
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