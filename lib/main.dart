import 'package:flutter/material.dart';
import 'package:musicPlayer/models/Provider.dart';
import 'package:musicPlayer/models/playListDB.dart';
import 'package:musicPlayer/models/songController.dart';
import 'package:musicPlayer/screens/library.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProviderClass()),
        ChangeNotifierProvider(create: (_) => PlayListDB()),
        ChangeNotifierProvider(create: (_) => SongController()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[100],
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Library(),
    );
  }
}
