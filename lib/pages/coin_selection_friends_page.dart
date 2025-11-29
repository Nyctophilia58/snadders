import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snadders/services/shared_prefs_service.dart';
import 'package:snadders/widgets/buttons/exit_button.dart';
import '../services/iap_services.dart';
import 'friends_match_page.dart';

class CoinSelectionFriendsPage extends StatefulWidget {
  final IAPService iapService;
  final int coins;
  final int diamonds;

  const CoinSelectionFriendsPage({
    super.key,
    required this.iapService,
    required this.coins,
    required this.diamonds,
  });

  @override
  State<CoinSelectionFriendsPage> createState() => _CoinSelectionFriendsPageState();
}

class _CoinSelectionFriendsPageState extends State<CoinSelectionFriendsPage> {
  final SharedPrefsService _prefsService = SharedPrefsService();
  final joinController = TextEditingController();
  String? joinedGameId;

  bool gameCreated = false;
  String gameId = '';
  String username = '';
  String profileImage = '';

  Future<void> createGame() async {
    final userId = await _prefsService.getUserId();
    final userDoc = await FirebaseFirestore.instance.collection('googleUsers').doc(userId).get();
    final userData = userDoc.data();

    if (userData == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User data not found.'), behavior: SnackBarBehavior.floating,));
      return;
    }

    if ((userData['coins'] ?? 0) < 100) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not enough coins to create a room.'), behavior: SnackBarBehavior.floating,));
      return;
    }

    final gameDoc = await FirebaseFirestore.instance.collection('rooms').doc();
    await gameDoc.set({
      'player1': {
        'coins': userData['coins'],
        'diamonds': userData['diamonds'],
        'profileImage': userData['profileImage'],
        'index': 0,
        'uid': userId,
        'username': userData['username'],
      },
      'player2': {
        'coins': 0,
        'diamonds': 0,
        'profileImage': '',
        'index': 1,
        'uid': '',
        'username': '',
      },
      'playerPositions': [1, 1],
      'status': 'waiting',
      'turnIndex': 0,
      'boardNumber': 1,
      'currentPlayerIndex': 0,
      'winner' : null,
      'createdAt': FieldValue.serverTimestamp(),
      'lastMove': null,
    });

    setState(() {
      gameCreated = true;
      gameId = gameDoc.id;
      username = userData['username'];
      profileImage = userData['profileImage'];
    });
  }

  Future<void> joinGame(String gameId) async {
    final userId = await _prefsService.getUserId();
    final roomDoc = FirebaseFirestore.instance.collection('rooms').doc(gameId);
    final roomSnapshot = await roomDoc.get();

    // Check if room exists
    if (!roomSnapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Room not found.'), behavior: SnackBarBehavior.floating,));
      return;
    }

    final room = roomSnapshot.data();

    // Check if room is full
    if (room?['player2']['uid'] != '') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room already full.')),
      );
      return;
    }

    // Check if game already started
    if (room?['status'] == 'playing') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Game already started.')),
      );
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('googleUsers')
        .doc(userId)
        .get();
    final userData = userDoc.data();

    if (userData == null || (userData['coins']) < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough coins to join the room.'), behavior: SnackBarBehavior.floating,),
      );
      return;
    }

    await roomDoc.update({
      'player2': {
        'coins': userData['coins'],
        'diamonds': userData['diamonds'],
        'profileImage': userData['profileImage'],
        'index': 2,
        'uid': userId,
        'username': userData['username'],
      },
    });
    setState(() {
      joinedGameId = gameId;
      username = userData['username'];
      profileImage = userData['profileImage'];
    });

    Navigator.push(context, MaterialPageRoute(builder: (_) => FriendsMatchPage(iapService: widget.iapService, gameId: gameId, isPlayerOne: false, username: username, profileImage: profileImage)));
  }

  @override
  void dispose() {
    joinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.yellowAccent),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.coins}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.diamond, color: Colors.cyanAccent),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.diamonds}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Card(
            color: Colors.transparent,
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.greenAccent.shade700.withOpacity(0.9),
                    Colors.greenAccent.withOpacity(0.9),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purpleAccent.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),

              child: DefaultTabController(
                length: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFF8B195).withOpacity(0.9),
                            const Color(0xFFF67280).withOpacity(0.9),
                            const Color(0xFFC06C84).withOpacity(0.9),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TabBar(
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.black,
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(text: "CREATE"),
                          Tab(text: "JOIN"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      height: 270,
                      child: TabBarView(
                        children: [
                          Column(
                            children: [
                              _buildCoinsCard(),
                              const SizedBox(height: 20),
                              _buildCreateButton(context),
                            ],
                          ),

                          Column(
                            children: [
                              const SizedBox(height: 20),
                              _joinRoomInput(),
                              const SizedBox(height: 20),
                              _buildJoinButton(context),
                              if (joinedGameId != null) ...[
                                const SizedBox(height: 20),
                                Row (
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Joined Game ID: $joinedGameId',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.copy, color: Colors.white70),
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(text: joinedGameId!));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Game ID copied to clipboard.'))
                                        );
                                      },
                                    )
                                  ]
                                )
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          ExitButton(onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  Widget _buildCoinsCard() {
    return Flexible(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.yellow.shade600.withOpacity(0.9),
              Colors.orange.shade400.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.orangeAccent.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.monetization_on_rounded,
              color: Colors.deepOrange.shade900,
              size: 28,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.85),
                    Colors.grey.shade300.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "100",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.purple,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Entry Amount',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent.shade100,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _joinRoomInput() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: joinController,
        style: const TextStyle(color: Colors.black54, fontSize: 18, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: "Enter Room Code",
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white70),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateButton(BuildContext context, ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          await createGame();
          if (mounted && gameCreated) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => FriendsMatchPage(iapService: widget.iapService, gameId: gameId, isPlayerOne: true, username: username, profileImage: profileImage)));
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pinkAccent.shade400,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 10,
        ),
        child: const Text(
          'Create Room',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildJoinButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // keyboard vanish
          FocusScope.of(context).unfocus();
          joinGame(joinController.text.trim());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 10,
        ),
        child: const Text(
          'Join Room',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
