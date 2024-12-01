import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:calm_path/core/configs/theme/app_colors.dart';
import 'package:calm_path/core/configs/theme/color_palette.dart';

class NotesScreen extends StatefulWidget {
  final String? entryId;

  NotesScreen({this.entryId});

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _noteController = TextEditingController();
  Color _selectedColor = AppColors.lightBackground; // Default background color
  final _journalRef = FirebaseDatabase.instance.ref("gratitude_journal");
  File? _selectedImage; // Store the selected photo
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.entryId != null) {
      _loadNote();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.entryId == null && _selectedColor == AppColors.lightBackground) {
      _selectedColor = Theme.of(context).scaffoldBackgroundColor;
    }
  }

  void _loadNote() async {
    final snapshot = await _journalRef.child(widget.entryId!).get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        _noteController.text = data['note'] ?? "";
        _selectedColor = Color(int.parse(data['color'] ?? "0xFFFFFFFF"));
      });
    }
  }

  void _saveNote() async {
    final noteData = {
      'date': DateTime.now().toIso8601String(),
      'note': _noteController.text,
      'color': _selectedColor.value.toString(),
    };

    if (widget.entryId == null) {
      await _journalRef.push().set(noteData);
    } else {
      await _journalRef.child(widget.entryId!).update(noteData);
    }

    Navigator.pop(context);
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take a Photo"),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Pick a Background Color"),
          content: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: ColorPalette.colors.map((color) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.grey),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showGratitudeIdeas() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Things to be Grateful For"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              ListTile(
                leading: Icon(Icons.favorite, color: Colors.red),
                title: Text("Family and Friends"),
              ),
              ListTile(
                leading: Icon(Icons.nature, color: Colors.green),
                title: Text("Nature and Fresh Air"),
              ),
              ListTile(
                leading: Icon(Icons.light, color: Colors.yellow),
                title: Text("New Opportunities"),
              ),
              ListTile(
                leading: Icon(Icons.home, color: Colors.blue),
                title: Text("A Safe Place to Live"),
              ),
              ListTile(
                leading: Icon(Icons.fastfood, color: Colors.orange),
                title: Text("Delicious Meals"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom; // Keyboard padding
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.entryId == null ? "New Note" : "Edit Note",
          style: const TextStyle(fontFamily: 'Satoshi'),
        ),
        backgroundColor: _selectedColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _saveNote,
            tooltip: "Save",
          ),
        ],
      ),
      body: Container(
        color: _selectedColor.withOpacity(0.8),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedImage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    TextField(
                      controller: _noteController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText:
                            "I am so happy and grateful for ____, because ____.",
                        filled: true,
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none, // Removes the border
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.transparent), // Transparent border
                        ),
                        hintStyle: TextStyle(
                          color: AppColors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      style: const TextStyle(fontSize: 18, fontFamily: 'Satoshi'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: AppColors.darkGrey,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPadding), // Adjust to keyboard
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.color_lens, color: Colors.white),
                onPressed: _showColorPicker,
                tooltip: "Pick Color",
              ),
              IconButton(
                icon: const Icon(Icons.lightbulb, color: Colors.white),
                onPressed: _showGratitudeIdeas,
                tooltip: "Ideas",
              ),
              IconButton(
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                onPressed: _showPhotoOptions,
                tooltip: "Add Photo",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
