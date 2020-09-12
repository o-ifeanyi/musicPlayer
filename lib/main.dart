import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:musicPlayer/constants.dart';
import 'package:musicPlayer/models/Provider.dart';
import 'package:musicPlayer/models/playListDB.dart';
import 'package:musicPlayer/models/share.dart';
import 'package:musicPlayer/models/songController.dart';
import 'package:musicPlayer/screens/splash.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AudioSession.instance.then((session) {
    session.configure(AudioSessionConfiguration.music());
  });
  SharedPreferences.getInstance().then((pref) {
    int theme = pref.getInt('theme') ?? 0;
    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => ProviderClass(kThemes[theme])),
        ChangeNotifierProvider(create: (_) => PlayListDB()),
        ChangeNotifierProvider(create: (_) => SongController()),
        ChangeNotifierProvider(create: (_) => ShareClass()),
      ],
      child: MyApp(theme: kThemes[theme]),
    ));
  });
}

class MyApp extends StatelessWidget {
  MyApp({this.theme});
  final ThemeData theme;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vibe player',
      theme: Provider.of<ProviderClass>(context).getTheme(),
      home: SplashScreen(theme),
    );
  }
}
