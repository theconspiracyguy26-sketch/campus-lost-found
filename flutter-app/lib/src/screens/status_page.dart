import 'package:flutter/material.dart';
import '../services/appwrite_service.dart';

class StatusPage extends StatefulWidget {
  @override
  _StatusPageState createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  List items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  _load() async {
    try {
      items = await AppwriteService.listMyItems();
    } catch (e) {
      print(e);
    } finally {
      setState(() => loading = false);
    }
  }

  Widget _tile(i) {
    return ListTile(
      title: Text(i['title'] ?? ''),
      subtitle: Text('Status: ${i['status'] ?? 'open'}'),
      trailing: i['status'] == 'open' ? Text('Open') : Text('Resolved'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Status')), body: loading ? Center(child: CircularProgressIndicator()) : ListView(children: items.map<Widget>(_tile).toList()));
  }
}
