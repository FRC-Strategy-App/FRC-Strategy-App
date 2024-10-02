// ignore: file_names
import 'package:flutter/material.dart';
import 'package:frc_stategy_app/classes/management/fetch_match_data.dart';

class TeamCard extends StatelessWidget {
  final MatchData match; 
  final String Function(int context) timeToDate;
  final int Function(int? actualTime, int? time) isTimeNull;
  final Future<void> Function(BuildContext context) pushButton;
  
  const TeamCard({
    Key? key,
    required this.match,
    required this.isTimeNull,
    required this.timeToDate,
    required this.pushButton
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(
          children: [
          (isTimeNull(match.actualTime, match.Time) == 0)
            ? Text('Predicted Time: ${timeToDate(match.predictedTime)}',
                style: const TextStyle(fontSize: 20))
            : (isTimeNull(match.actualTime, match.Time) == 1)
              ? const Text('TBA', style: TextStyle(fontSize: 20))
              : Text('Time: ${timeToDate(match.actualTime)}',
                  style: const TextStyle(fontSize: 20)),
            // Text('Time: ${timeToDate(matchTime as int)}', style : const TextStyle(
            //   fontWeight: FontWeight.bold,
            //   fontSize: 20
            // ),),
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
}