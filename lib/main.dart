import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:musicPlayer/screens/edit_info.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:musicPlayer/screens/library.dart';
import 'package:musicPlayer/screens/now_playing.dart';
import 'package:musicPlayer/screens/playList.dart';
import 'package:musicPlayer/screens/playing_from.dart';
import 'package:musicPlayer/screens/settings.dart';
import 'package:musicPlayer/util/themes.dart';
import 'package:musicPlayer/providers/all_songs.dart';
import 'package:musicPlayer/providers/playList_database.dart';
import 'package:musicPlayer/providers/mark_songs.dart';
import 'package:musicPlayer/providers/song_controller.dart';
import 'package:musicPlayer/screens/splash.dart';

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
            create: (_) => ProviderClass(themeData: kThemes[theme])),
        ChangeNotifierProvider(create: (_) => PlayListDB()),
        ChangeNotifierProvider(create: (_) => SongController()),
        ChangeNotifierProvider(create: (_) => MarkSongs()),
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
      debugShowCheckedModeBanner: false,
      title: 'Vibe player',
      theme: Provider.of<ProviderClass>(context).getTheme(),
      home: SplashScreen(theme),
      routes: {
        Library.pageId: (ctx) => Library(),
        EditInfo.pageId: (ctx) => EditInfo(),
        NowPlaying.pageId: (ctx) => NowPlaying(),
        PlayList.pageId: (ctx) => PlayList(),
        PlayingFrom.pageId: (ctx) => PlayingFrom(),
        Settings.pageId: (ctx) => Settings(),
      },
    );
  }
}
