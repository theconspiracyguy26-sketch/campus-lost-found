import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/appwrite_service.dart';

class LostPage extends StatefulWidget {
  @override
  _LostPageState createState() => _LostPageState();
}

class _LostPageState extends State<LostPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  File? _imageFile;
  bool _loading = false;

  Future<void> _pickImage() async {
    final p = ImagePicker();
    final xfile = await p.pickImage(source: ImageSource.camera) ?? await p.pickImage(source: ImageSource.gallery);
    if (xfile == null) return;
    setState(() => _imageFile = File(xfile.path));

    // Autofill description using BLIP caption
    try {
      setState(() => _loading = true);
      final caption = await AppwriteService.fetchCaptionFromModelServer(_imageFile!);
      if (caption != null && caption.isNotEmpty) {
        _descCtrl.text = caption;
      }
    } catch (e) {
      print('Caption failed: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      String? fileId;
      List<double>? embedding;

      if (_imageFile != null) {
        // upload image to Appwrite storage
        fileId = await AppwriteService.uploadImage(_imageFile!.path);
        // get embedding from model server
        embedding = await AppwriteService.getImageEmbedding(_imageFile!);
      } else if (_descCtrl.text.trim().isNotEmpty) {
        embedding = await AppwriteService.getTextEmbedding(_descCtrl.text.trim());
      }

      final item = {
        'type': 'lost',
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'imageFileId': fileId,
        'collegeId': AppwriteService.currentCollegeId,
        'userId': AppwriteService.currentUserId,
        'status': 'open',
        'createdAt': DateTime.now().toUtc().toIso8601String(),
        'embedding': embedding,
        'caption': _descCtrl.text.trim(),
      };

      await AppwriteService.createItem(item);

      // trigger server-side matching via Appwrite Function (server will fetch candidates and run match)
      await AppwriteService.triggerMatchJob();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lost item posted')));
      Navigator.pop(context);
    } catch (e) {
      print('submit error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to post: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Report Lost')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey)),
                  child: _imageFile == null
                      ? Center(child: Text('Tap to add photo (optional)'))
                      : Image.file(_imageFile!, fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 12),
              TextFormField(controller: _titleCtrl, decoration: InputDecoration(labelText: 'Title'), validator: (v) => v!.isEmpty ? 'Required' : null),
              SizedBox(height: 8),
              TextFormField(controller: _descCtrl, maxLines: 4, decoration: InputDecoration(labelText: 'Description (you can autofill using image)'), validator: (v) => v!.isEmpty ? 'Describe item' : null),
              SizedBox(height: 8),
              TextFormField(controller: _locationCtrl, decoration: InputDecoration(labelText: 'Location (optional)')),
              SizedBox(height: 16),
              ElevatedButton(onPressed: _loading ? null : _submit, child: _loading ? CircularProgressIndicator() : Text('Post Lost'))
            ],
          ),
        ),
      ),
    );
  }
}
