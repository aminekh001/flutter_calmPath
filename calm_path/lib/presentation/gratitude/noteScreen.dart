import 'dart:convert'; // Import for Base64 encoding/decoding
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:calm_path/core/configs/theme/app_colors.dart';
import 'package:calm_path/core/configs/theme/color_palette.dart';
import 'package:intl/intl.dart';
import 'package:calm_path/common/widgets/app_bar/app_bar.dart';

class NotesScreen extends StatefulWidget {
  final String? entryId;

  NotesScreen({this.entryId});

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _noteController = TextEditingController();
  Color _selectedColor = ColorPalette.colors.first;
  final _journalRef = FirebaseDatabase.instance.ref("gratitude_journal");
  File? _selectedImage; // Store the selected photo
  String? _base64Image; // Store Base64 encoded string for the photo
  final ImagePicker _picker = ImagePicker();

  String? _creationDate;
  String? _lastModifiedDate;

  @override
  void initState() {
    super.initState();
    if (widget.entryId != null) {
      _loadNote();
    } else {
      _initializeDates();
    }
  }

  void _initializeDates() {
    final now = DateTime.now();
    final formattedDate = _formatDateTime(now);
    _creationDate = formattedDate;
    _lastModifiedDate = formattedDate;
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('EEEE, MMMM d yyyy HH:mm').format(dateTime);
  }

  Future<void> _loadNote() async {
    final snapshot = await _journalRef.child(widget.entryId!).get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        _noteController.text = data['note'] ?? "";
        _selectedColor = Color(int.parse(data['color'] ?? "0xFFFFFFFF"));
        _creationDate = data['creationDate'] ?? "";
        _lastModifiedDate = data['lastModifiedDate'] ?? _creationDate;

        if (data['imageBase64'] != null) {
          _base64Image = data['imageBase64'];
          _selectedImage = null;
        } else {
          _base64Image = null;
        }
      });
    }
  }

  Future<void> _saveNote() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final now = DateTime.now();

    if (_selectedImage != null) {
      _base64Image = base64Encode(await _selectedImage!.readAsBytes());
    }

    if (widget.entryId == null) {
      _initializeDates();
    } else {
      _lastModifiedDate = _formatDateTime(now); // Update last modified date
    }

    final noteData = {
      'uid': user.uid,
      'creationDate': _creationDate,
      'lastModifiedDate': _lastModifiedDate,
      'note': _noteController.text,
      'color': _selectedColor.value.toString(),
      'imageBase64': _base64Image,
    };

    if (widget.entryId == null) {
      await _journalRef.push().set(noteData);
    } else {
      await _journalRef.child(widget.entryId!).update(noteData);
    }

    Navigator.pop(context);
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _base64Image = null;
      });
    }
  }

  Future<void> _takePhotoWithCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _base64Image = null;
      });
    }
  }

  void _showOverflowMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.color_lens),
                title: const Text("Pick Color"),
                onTap: () {
                  Navigator.pop(context);
                  _showColorPicker();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Add Picture"),
                onTap: () {
                  Navigator.pop(context);
                  _showPhotoOptions();
                },
              ),
              ListTile(
                leading: const Icon(Icons.lightbulb),
                title: const Text("Ideas"),
                onTap: () {
                  Navigator.pop(context);
                  _showGratitudeIdeas();
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
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take a Photo"),
                onTap: () {
                  Navigator.pop(context);
                  _takePhotoWithCamera();
                },
              ),
            ],
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
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
    return Scaffold(
      appBar: BasicAppBar(

        title: Text(_lastModifiedDate ?? "New Note"),
        backgroundColor: _selectedColor.withOpacity(0.6),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showOverflowMenu,
          ),
        ],
      ),
      body: Container(
        color: _selectedColor.withOpacity(0.5),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_base64Image != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: MemoryImage(base64Decode(_base64Image!)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
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
            Expanded(
              child: TextField(
                controller: _noteController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: "I am so happy and grateful for ____, because ____.",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: AppColors.grey, fontStyle: FontStyle.italic),
                ),
                style: const TextStyle(fontSize: 18, fontFamily: 'Satoshi'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: _saveNote,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: AppColors.primary,
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          child: Text("Save", style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
      ),
    );
  }
}
