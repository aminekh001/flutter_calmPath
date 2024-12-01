import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'noteScreen.dart';
import 'package:calm_path/core/configs/theme/app_colors.dart';

class GratitudeListScreen extends StatefulWidget {
  @override
  _GratitudeListScreenState createState() => _GratitudeListScreenState();
}

class _GratitudeListScreenState extends State<GratitudeListScreen> {
  final DatabaseReference journalRef =
      FirebaseDatabase.instance.ref("gratitude_journal");

  bool _isSearching = false;
  String _searchQuery = "";
  List<Map<dynamic, dynamic>> _allEntries = [];
  List<Map<dynamic, dynamic>> _filteredEntries = [];

  @override
  void initState() {
    super.initState();
    _fetchEntries();
  }

  void _fetchEntries() {
    journalRef.onValue.listen((event) {
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

  void _filterEntries(String query) {
    setState(() {
      _searchQuery = query;
      _filteredEntries = _allEntries
          .where((entry) =>
              (entry['note'] ?? "")
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              (entry['date'] ?? "")
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
        _searchQuery = "";
        _filteredEntries = _allEntries;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                onChanged: _filterEntries,
                decoration: InputDecoration(
                  hintText: "Search...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: AppColors.grey),
                ),
                style: const TextStyle(color: Colors.white),
                autofocus: true,
              )
            : const Text("Gratitude Journal"),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: Padding(
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
                  final date = entry['date'] ?? "Unknown Date";
                  final note = entry['note'] ?? "No note available";
                  final colorHex = entry['color'] ?? "0xFF6A1B9A";
                  final color = Color(int.parse(colorHex));

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              NotesScreen(entryId: entry['key']),
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
                                date,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                note,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NotesScreen()),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
        tooltip: 'Add Entry',
      ),
    );
  }
}