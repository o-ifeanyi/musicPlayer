// import 'package:device_preview/device_preview.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:musicPlayer/constants.dart';
import 'package:musicPlayer/models/Provider.dart';
import 'package:musicPlayer/models/playListDB.dart';
import 'package:musicPlayer/models/songController.dart';
import 'package:musicPlayer/screens/library.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.getInstance().then((pref) {
    bool isDark = pref.getBool('theme') ?? false;
    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => ProviderClass(isDark ? kDarkTheme : kLightTheme)),
        ChangeNotifierProvider(create: (_) => PlayListDB()),
        ChangeNotifierProvider(create: (_) => SongController()),
      ],
      child: MyApp(),
    ));
  });

  // DevicePreview(
  //   enabled: !kReleaseMode,
  //   builder: (context) {
  //     return MultiProvider(
  //       providers: [
  //         ChangeNotifierProvider(create: (_) => ProviderClass()),
  //         ChangeNotifierProvider(create: (_) => PlayListDB()),
  //         ChangeNotifierProvider(create: (_) => SongController()),
  //       ],
  //       child: MyApp(),
  //     );
  //   },
  // ),
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // locale: DevicePreview.of(context).locale,
      // builder: DevicePreview.appBuilder,
      title: 'Flutter Demo',
      theme: Provider.of<ProviderClass>(context).getTheme(),
      home: Library(),
    );
  }
}
