import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:calm_path/common/widgets/app_bar/app_bar.dart';
import 'package:calm_path/common/widgets/app_bar/bottom_nav_bar.dart';
import 'noteScreen.dart';
import 'package:calm_path/core/configs/theme/app_colors.dart';

class GratitudeListScreen extends StatefulWidget {
  @override
  _GratitudeListScreenState createState() => _GratitudeListScreenState();
}

class _GratitudeListScreenState extends State<GratitudeListScreen> {
  final DatabaseReference journalRef =
      FirebaseDatabase.instance.ref("gratitude_journal");
  final User? currentUser = FirebaseAuth.instance.currentUser;

  bool _isSearching = false;
  List<Map<dynamic, dynamic>> _allEntries = [];
  List<Map<dynamic, dynamic>> _filteredEntries = [];

  @override
  void initState() {
    super.initState();
    _fetchEntries();
  }

  void _fetchEntries() {
    if (currentUser != null) {
      journalRef
          .orderByChild("uid")
          .equalTo(currentUser!.uid)
          .onValue
          .listen((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;

        if (data != null) {
          setState(() {
            _allEntries = data.entries
                .map((e) => {"key": e.key, ...e.value as Map<dynamic, dynamic>})
                .toList();
            _filteredEntries = _allEntries;
          });
        } else {
          setState(() {
            _allEntries = [];
            _filteredEntries = [];
          });
        }
      });
    }
  }

  void _filterEntries(String query) {
    setState(() {
      _filteredEntries = _allEntries
          .where((entry) =>
              (entry['lastModifiedDate'] ?? "")
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _filteredEntries = _allEntries;
      }
    });
  }

  Future<void> _deleteEntry(String key) async {
    await journalRef.child(key).remove();
  }

  void _confirmDelete(BuildContext context, String key) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Entry"),
          content: const Text("Are you sure you want to delete this entry?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteEntry(key);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(String date) {
    try {
      final parts = date.split(' ');
      final day = parts[0];
      final monthAndDate = parts.sublist(1, 3).join(' ');
      final year = parts[3];
      return "$day $monthAndDate $year";
    } catch (e) {
      print("Error parsing date: $e");
      return "Invalid Date";
    }
  }

  String _extractTime(String date) {
    try {
      final parts = date.split(' ');
      return parts[4];
    } catch (e) {
      print("Error extracting time: $e");
      return "Invalid Time";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: BasicAppBar(
        title: _isSearching
            ? TextField(
                onChanged: _filterEntries,
                decoration: const InputDecoration(
                  hintText: "Search by date...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: AppColors.grey),
                ),
                style: const TextStyle(color: Colors.white),
                autofocus: true,
              )
            : const Text("Gratitude Journal"),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/grat.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.8),
                  BlendMode.dstATop,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: _filteredEntries.isEmpty
                ? const Center(
                    child: Text(
                      "No entries found.",
                      style: TextStyle(fontSize: 18, color: AppColors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredEntries.length,
                    itemBuilder: (context, index) {
                      final entry = _filteredEntries[index];
                      final lastModified = entry['lastModifiedDate'] ?? "Unknown Date";
                      final formattedDate = _formatDate(lastModified);
                      final time = _extractTime(lastModified);
                      final colorHex = entry['color'] ?? "0xFF6A1B9A";
                      final color = Color(int.parse(colorHex));
                      final key = entry['key'];

                      return Slidable(
                        key: Key(key),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) => _confirmDelete(context, key),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NotesScreen(entryId: entry['key']),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Icon(Icons.favorite, color: Colors.white),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      formattedDate,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      time,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const Icon(Icons.favorite, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NotesScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        tooltip: 'Add Entry',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 1),
    );
  }
}
