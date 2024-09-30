import 'dart:io';
import 'package:feedback/feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

final Uri _url = Uri.parse("https://github.com/FRC-Strategy-App/FRC-Strategy-App");

class FeedbackFeature extends StatefulWidget {
  const FeedbackFeature({super.key});

  @override
  State<FeedbackFeature> createState() => _FeedbackFeatureState();
}

class _FeedbackFeatureState extends State<FeedbackFeature> {
Widget build(BuildContext context) {
  return BetterFeedback(
    theme: FeedbackThemeData(
      background: Colors.black87,
      feedbackSheetColor: Colors.white,
      drawColors: [
        Colors.red,
        Colors.green,
        Colors.blue,
        Colors.yellow,
        Colors.white,
      ],
    ),
    darkTheme: FeedbackThemeData.dark(),
    localizationsDelegates: [
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalFeedbackLocalizationsDelegate(),
    ],
    localeOverride: const Locale('en'),
    child: 
      const FeedbackScreen()
  );
}
}

class FeedbackScreen extends StatelessWidget{
  const FeedbackScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.transparent,
      appBar: AppBar(
        title: const Text('Feedback', style: TextStyle(color: Colors.white, fontSize: 20)),
        backgroundColor: Colors.white10,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 10,),
              if(Platform.isMacOS || Platform.isAndroid || Platform.isIOS)...{
                Center(
                  child: SizedBox(
                    width: 200,
                    height: 70,
                    child:ElevatedButton(
                      onPressed: () {
                        BetterFeedback.of(context).show(
                          (UserFeedback feedback) async{
                            // This is jut an alert for testing feedbacks, can be removed if needed. 
                            alertFeedbackFunction(context, feedback);
                          }
                        );
                      },
                      child: const Text("Provide Feedback"),
                    ),
                  ),
                ),
              },
              const SizedBox(height: 20,),
              // This does not work on desktop, known for ipad.
              if(!kIsWeb && (Platform.isAndroid || Platform.isIOS)) ...{
                Center(
                  child: SizedBox(
                    width: 200,
                    height: 70,
                    child:ElevatedButton(
                      onPressed: () async {
                        BetterFeedback.of(context).show(
                          (UserFeedback feedback) async{
                            final screenshotFilePath =
                              await writeImageToStorage(feedback.screenshot);
                            final Email email = Email(
                              body: feedback.text,
                              subject: "FRC Strategy Feedback",
                              recipients: ['justindujun@gmail.com'],
                              attachmentPaths: [screenshotFilePath],
                              cc:[],
                              bcc:[],
                              isHTML: false,
                            );
                            await FlutterEmailSender.send(email);
                          }
                        );
                      },
                      child: const Text(
                        'E-mail Feedback'
                      ),
                    
                    )
                  ),
                ),
              },
              const SizedBox(height: 20,),
              const Center(
                child:SizedBox(
                  width: 200,
                  height: 70,
                  child: ElevatedButton(
                    onPressed: _launchUrl,
                    child: Text("Github")
                  ),
                )
              ),
            ],
          )
        ),
      ),
    );
  }
}

void alertFeedbackFunction(BuildContext context, UserFeedback feedback) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Feedback Submitted'),
          content: Text('Feedback message: ${feedback.text}'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

Future<void> _launchUrl() async {
  if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
  }
}

Future<String> writeImageToStorage(Uint8List feedbackScreenshot) async {
  final Directory output = await getTemporaryDirectory();
  final String screenshotFilePath = '${output.path}/feedback.png';
  final File screenshotFile = File(screenshotFilePath);
  await screenshotFile.writeAsBytes(feedbackScreenshot);
  return screenshotFilePath;
}
