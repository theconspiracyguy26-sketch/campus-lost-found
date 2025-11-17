import 'package:flutter/material.dart';
import '../services/appwrite_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PublicListingsPage extends StatefulWidget {
  @override
  _PublicListingsPageState createState() => _PublicListingsPageState();
}

class _PublicListingsPageState extends State<PublicListingsPage> {
  List items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  _load() async {
    try {
      final res = await AppwriteService.listPublicItems();
      setState(() {
        items = res;
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Public Listings')),
      body: loading ? Center(child: CircularProgressIndicator()) : ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) {
            final it = items[i];
            return ListTile(
              leading: it['imageUrl'] != null ? CachedNetworkImage(imageUrl: it['imageUrl'], width: 60, height: 60, fit: BoxFit.cover) : null,
              title: Text(it['title'] ?? ''),
              subtitle: Text(it['description'] ?? ''),
            );
          }
      ),
    );
  }
}
