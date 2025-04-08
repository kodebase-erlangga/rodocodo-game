// import 'package:flutter/material.dart';
// import 'package:rodocodo_game/main.dart'; // Ensure this imports the routeObserver
// import 'package:rodocodo_game/opsiLevel.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'game/game_widget.dart';

// class LevelSelectionScreen extends StatefulWidget {
//   const LevelSelectionScreen({super.key});

//   @override
//   State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
// }

// class _LevelSelectionScreenState extends State<LevelSelectionScreen>
//     with RouteAware {
//   final PageController _pageController = PageController(initialPage: 0);
//   int _currentPage = 0;
//   late Future<Map<int, int>> _starsFuture;

//   @override
//   void initState() {
//     super.initState();
//     _starsFuture = _loadStars();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // Subscribe to the RouteObserver
//     routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
//   }

//   @override
//   void dispose() {
//     // Unsubscribe from the RouteObserver
//     routeObserver.unsubscribe(this);
//     super.dispose();
//   }

//   @override
//   void didPopNext() {
//     // Called when the user returns to this screen
//     setState(() {
//       _starsFuture = _loadStars(); // Refresh the stars data
//     });
//   }

//   Future<Map<int, int>> _loadStars() async {
//     final prefs = await SharedPreferences.getInstance();
//     return {
//       1: prefs.getInt('level1') ?? 0,
//       2: prefs.getInt('level2') ?? 0,
//       3: prefs.getInt('level3') ?? 0,
//       4: prefs.getInt('level4') ?? 0,
//       5: prefs.getInt('level5') ?? 0,
//       6: prefs.getInt('level6') ?? 0,
//     };
//   }

//   Future<void> _updateStars(int level, int stars) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('level$level', stars);
//     setState(() => _starsFuture = _loadStars());
//   }

//   Widget _buildLevelCard(int level, int stars, bool isUnlocked) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(15),
//         onTap: isUnlocked
//             ? () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => GameScreen(
//                       initialLevel: level,
//                       onLevelCompleted: (stars) => _updateStars(level, stars),
//                     ),
//                   ),
//                 );
//               }
//             : null,
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(15),
//             color: isUnlocked ? Colors.blue[50] : Colors.grey[200],
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 isUnlocked ? Icons.gamepad : Icons.lock,
//                 size: 40,
//                 color: isUnlocked ? Colors.blue : Colors.grey,
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 'Level $level',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: isUnlocked ? Colors.blue : Colors.grey,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: List.generate(
//                     3,
//                     (index) => Icon(
//                           Icons.star,
//                           color: index < stars ? Colors.amber : Colors.grey,
//                           size: 24,
//                         )),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Pilih Level'),
//         backgroundColor: Colors.blueAccent,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => OpsiLevel()),
//             );
//           },
//         ),
//       ),
//       body: FutureBuilder<Map<int, int>>(
//         future: _starsFuture,
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           final stars = snapshot.data!;
//           return Stack(
//             children: [
//               PageView.builder(
//                 controller: _pageController,
//                 onPageChanged: (page) => setState(() => _currentPage = page),
//                 itemCount: 2,
//                 itemBuilder: (context, page) {
//                   final levels = page == 0 ? [1, 2, 3] : [4, 5, 6];
//                   return GridView.count(
//                     padding: const EdgeInsets.all(16),
//                     crossAxisCount:
//                         MediaQuery.of(context).size.width > 600 ? 3 : 2,
//                     childAspectRatio: 1.0,
//                     mainAxisSpacing: 16,
//                     crossAxisSpacing: 16,
//                     children: levels.map((level) {
//                       final isUnlocked =
//                           level == 1 || (level > 1 && stars[level - 1]! > 0);
//                       return _buildLevelCard(
//                           level, stars[level] ?? 0, isUnlocked);
//                     }).toList(),
//                   );
//                 },
//               ),
//               if (_currentPage > 0)
//                 Positioned(
//                   left: 20,
//                   top: MediaQuery.of(context).size.height / 2,
//                   child: IconButton(
//                     icon: const Icon(Icons.arrow_back_ios, size: 40),
//                     onPressed: () => _pageController.previousPage(
//                       duration: const Duration(milliseconds: 300),
//                       curve: Curves.easeInOut,
//                     ),
//                   ),
//                 ),
//               if (_currentPage < 1)
//                 Positioned(
//                   right: 20,
//                   top: MediaQuery.of(context).size.height / 2,
//                   child: IconButton(
//                     icon: const Icon(Icons.arrow_forward_ios, size: 40),
//                     onPressed: () => _pageController.nextPage(
//                       duration: const Duration(milliseconds: 300),
//                       curve: Curves.easeInOut,
//                     ),
//                   ),
//                 ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
