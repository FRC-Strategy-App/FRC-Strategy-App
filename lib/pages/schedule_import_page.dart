import 'package:flutter/material.dart';
import 'package:frc_stategy_app/classes/management/fetch_match_data.dart';
import 'package:frc_stategy_app/classes/management/file_management.dart';
import 'package:frc_stategy_app/classes/management/save_load_drawing.dart';
import 'package:frc_stategy_app/classes/team.dart';
import 'package:frc_stategy_app/pages/display_schedule.dart';
import 'package:frc_stategy_app/widgets/field/field_drawing.dart';
class ScheduleImportPage extends StatefulWidget {
  const ScheduleImportPage({super.key});

  @override
  _ScheduleImportPageState createState() => _ScheduleImportPageState();
}

class _ScheduleImportPageState extends State<ScheduleImportPage> {
  final TextEditingController apiKeyController = TextEditingController();
  final TextEditingController eventKeyController = TextEditingController();
  final TextEditingController teamNumberController = TextEditingController();


  void _importSchedule() async {
    final apiKey = apiKeyController.text;
    final eventKey = eventKeyController.text;
    final teamNumber = teamNumberController.text;
    try {
      List<MatchData> matches = await fetchMatchData(apiKey, eventKey, teamNumber);
      
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => DisplaySchedule(matchData: matches,))
      );
      

      // for (var match in matches) {
      //   for (var phase in ['auto', 'teleop', 'endgame']) {
      //     await saveDrawing(
      //       eventKey,
      //       match.matchKey,
      //       phase,
      //       [], // initially empty lines
      //       [ // teams
      //         ...match.allianceTeams.map((team) => Team(name: team, color: Colors.blue)), // alliance teams
      //         ...match.opposingTeams.map((team) => Team(name: team, color: Colors.red)), // opposing teams
      //       ],
      //     );
      //   }
      // }

      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => FieldDrawing(eventKey: eventKey, matchKey: matches.first.matchKey, phase: 'auto')),
      // );
    } catch (e) {
      print('Failed to import schedule: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Import'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: apiKeyController,
              decoration: const InputDecoration(
                labelText: 'Blue Alliance API Key',
                hintText: 'Create account at: https://www.thebluealliance.com/account',
              ),
            ),
            TextField(
              controller: eventKeyController,
              decoration: const InputDecoration(
                hintText: 'Ex: 2024txhou',
                labelText: 'Event Key',
              ),
            ),
            TextField(
              controller: teamNumberController,
              decoration: const InputDecoration(
                hintText: 'Ex: 3847',
                labelText: 'Team Number',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _importSchedule,
              child: const Text('Import Schedule'),
            
            ),
          ],
        ),
      ),
    );
  }
}
