import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:frc_stategy_app/pages/drawings_page.dart';
import 'package:frc_stategy_app/pages/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'schedule_import_page.dart';
import 'manual_match_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FRC Strategy Whiteboard'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Menu'),
            ),
            ListTile(
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(context, 
                MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
            ListTile(
              title: const Text('Schedule Import'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScheduleImportPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Manual Match'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManualMatchPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Drawings'), // New ListTile for DrawingPage
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                const localFileSystem = LocalFileSystem();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProjectPage(
                    prefs: prefs,
                    pathplannerDirectory: localFileSystem.directory('C:\\Users\\nandji\\Documents\\test'), // Set this to your desired directory
                    fs: localFileSystem,
                  )),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Welcome to FRC Strategy Whiteboard!'),
            const SizedBox(height: 20), // spacing
            Image.asset(
              'assets/images/logo.png',
              width: 200, 
              height: 200, 
            ), 
          ],
        ),
      ),
    );
  }
}