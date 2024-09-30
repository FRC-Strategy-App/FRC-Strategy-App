import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

Future<List<MatchData>> fetchMatchData(String apiKey, String eventKey, String teamNumber) async {
  final url = 'https://www.thebluealliance.com/api/v3/team/frc$teamNumber/event/$eventKey/matches';
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'X-TBA-Auth-Key': apiKey,
    },
  );
  // 'https://www.thebluealliance.com/api/v3/team/frc3847/event/2024txhou/matches'

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    List<MatchData> matches = data.map((match) => MatchData.fromJson(match)).toList();
    return matches;
  } else {
    String errorMessage;
    try {
      Map<String, dynamic> errorData = json.decode(response.body);
      errorMessage = errorData['Error'] ?? 'Failed to load match data';
    } catch (e) {
      errorMessage = 'Failed to load match data';
    }
    throw Exception('API Error: $errorMessage');
  }
}

class MatchData {
  final String matchKey;
  final List<String> allianceTeams;
  final List<String> opposingTeams;

  MatchData({required this.matchKey, required this.allianceTeams, required this.opposingTeams});

  factory MatchData.fromJson(Map<String, dynamic> json) {
    List<String> allianceTeams = List<String>.from(json['alliances']['blue']['team_keys']);
    List<String> opposingTeams = List<String>.from(json['alliances']['red']['team_keys']);
    return MatchData(
      matchKey: json['key'],
      allianceTeams: allianceTeams,
      opposingTeams: opposingTeams,
    );
  }
}

