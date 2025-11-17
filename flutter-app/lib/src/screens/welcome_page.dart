import 'package:flutter/material.dart';
import '../widgets/gradient_scaffold.dart';
import 'lost_page.dart';
import 'found_page.dart';
import 'public_listings.dart';
import 'status_page.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientScaffold(
        child: Column(
          children: [
            SizedBox(height: 24),
            Text('Campus Lost & Found', style: TextStyle(fontSize: 24, color: Colors.white)),
            Expanded(
              child: GridView.count(
                padding: EdgeInsets.all(20),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _tile(context, 'Report Lost', Icons.search, LostPage()),
                  _tile(context, 'Report Found', Icons.report, FoundPage()),
                  _tile(context, 'Public Listings', Icons.public, PublicListingsPage()),
                  _tile(context, 'Status', Icons.history, StatusPage()),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext ctx, String title, IconData icon, Widget dest) {
    return GestureDetector(
      onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => dest)),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 48), SizedBox(height: 8), Text(title)])),
      ),
    );
  }
}
