import 'package:flutter/material.dart';
import 'package:frc_stategy_app/classes/management/fetch_match_data.dart';
import 'package:frc_stategy_app/pages/manual_match_page.dart';
import 'package:intl/intl.dart';
import 'package:frc_stategy_app/classes/teamCard.dart';
class DisplaySchedule extends StatelessWidget {
  final List<MatchData> matchData; 
  const DisplaySchedule({super.key, required this.matchData});
  // This is for drawing page
  // Future<void> pushButton(BuildContext context) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   const localFileSystem = LocalFileSystem();
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => ProjectPage(
  //       prefs: prefs,
  //       pathplannerDirectory: localFileSystem.directory('C:\\Users\\nandji\\Documents\\test'), // Set this to your desired directory
  //       fs: localFileSystem,
  //     )));
  // }
  Future<void> pushButton(BuildContext context) async{
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ManualMatchPage())
    );
  }

  String timeToDate(int context){
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(context * 1000);

    // Format the date
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(dateTime);
    return formattedDate;
  }

  int isTimeNull(int? actualTime, int? time) {
    if (actualTime == null && time != null) {
      return 0;
    } else if (actualTime == null && time == null) {
      return 1;
    }
    return 2;
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
        itemBuilder: (BuildContext context, int index) {
          final match = matchData[index];
          return TeamCard(
            match: match,
            isTimeNull: isTimeNull,
            timeToDate: timeToDate,
            pushButton: pushButton,
          );
        },
      ),
    );
  }
}