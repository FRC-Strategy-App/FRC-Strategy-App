import 'package:file/local.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frc_stategy_app/classes/management/fetch_match_data.dart';
import 'package:frc_stategy_app/pages/drawings_page.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DisplaySchedule extends StatelessWidget {
  final List<MatchData> matchData; 
  const DisplaySchedule({super.key, required this.matchData});

  Future<void> pushButton(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    const localFileSystem = LocalFileSystem();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProjectPage(
        prefs: prefs,
        pathplannerDirectory: localFileSystem.directory('C:\\Users\\nandji\\Documents\\test'), // Set this to your desired directory
        fs: localFileSystem,
      )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Schedule"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: matchData.length,
        itemBuilder: (BuildContext context, int index){
          final match = matchData[index];
          return Card(
            child: Column(
              children: [
                Text('Match: ${match.matchKey}', style : const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20
                ),),
                Text('Blue Alliance: ${match.allianceTeams.join(',')}'),
                Text('Red Alliance: ${match.opposingTeams.join(',')}'),
                TextButton(
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.black12)
                  ),
                  onPressed: ()=> pushButton(context),
                  child: const Text("Drawing", style: TextStyle(
                    fontSize: 15
                  ),),
                  )
              ],
            ),
            

          );
        }
      ),
    );
  }
}