import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:musicPlayer/components/custom_button.dart';
import 'package:musicPlayer/util/themes.dart';
import 'package:musicPlayer/providers/all_songs.dart';
import 'package:musicPlayer/util/config.dart';
import 'package:musicPlayer/providers/playList_database.dart';
import 'package:musicPlayer/providers/song_controller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  static const String pageId = '/settings';
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Container buildColoredCircle(Color color) {
    return Container(
      height: Config.yMargin(context, 7),
      width: Config.yMargin(context, 7),
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).textTheme.bodyText1.color),
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> coloredCircles = [
      buildColoredCircle(Colors.white), //white-ish
      buildColoredCircle(Color(0xFFEBCBDC)), //pink-ish
      buildColoredCircle(Color(0xFFA5C1EB)), //purple-ish
      buildColoredCircle(Color(0xFF011025)), //navy blue-ish
      buildColoredCircle(Color(0xFF282C31)), //gray-ish
      buildColoredCircle(Color(0xFF2A1E21)), //brown-ish
      buildColoredCircle(Color(0xFF1C2C29)), //green-ish
      buildColoredCircle(Color(0xFF1F1F2E)), //dark purple-ish
    ];
    TextStyle listStyle = TextStyle(
      fontSize: Config.textSize(context, 3.5),
      fontWeight: FontWeight.w400,
    );
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 30, bottom: 10),
                child: Row(
                  children: [
                    CustomButton(
                      child: Icons.arrow_back,
                      diameter: 12,
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(
                      width: Config.defaultSize(context, 27),
                    ),
                    Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: Config.textSize(context, 5),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                thickness: 1.0,
                color: Theme.of(context).dividerColor,
              ),
              Consumer<ProviderClass>(
                builder: (context, provider, child) {
                  return ListTile(
                    leading: Icon(Icons.color_lens),
                    title: Text(
                      'Theme',
                      style: listStyle,
                    ),
                    subtitle: Text(
                      'Change the look of the app',
                      style: listStyle.copyWith(
                        fontSize: Config.textSize(context, 3),
                      ),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Select theme.', style: listStyle),
                            content: Container(
                              height: Config.yMargin(context, 10),
                              width: MediaQuery.of(context).size.width,
                              child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: coloredCircles.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      provider.setTheme(kThemes[index]);
                                      SharedPreferences.getInstance()
                                          .then((pref) {
                                        pref.setInt('theme', index);
                                        Navigator.pop(context);
                                      });
                                    },
                                    child: coloredCircles[index],
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
              Consumer<SongController>(
                builder: (context, controller, child) {
                  return ListTile(
                    onTap: () {
                      controller.setUseArt(!controller.useArt);
                    },
                    leading: Icon(Icons.image),
                    title: Text(
                      'Use album cover',
                      style: listStyle,
                    ),
                    subtitle: Text(
                      'Show album cover of the song currently playing',
                      style: listStyle.copyWith(
                        fontSize: Config.textSize(context, 3),
                      ),
                    ),
                    trailing: Checkbox(
                      activeColor: Theme.of(context).accentColor,
                      value: controller.useArt,
                      onChanged: (bool newValue) {
                        controller.setUseArt(newValue);
                      },
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.refresh),
                title: Text(
                  'Reset playlist',
                  style: listStyle,
                ),
                subtitle: Text(
                  'Remove all playlist you created',
                  style: listStyle.copyWith(
                    fontSize: Config.textSize(context, 3),
                  ),
                ),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(
                              'This would delete the playlist you created.',
                              style: listStyle),
                          actions: [
                            FlatButton(
                              textColor: Theme.of(context).accentColor,
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel'),
                            ),
                            FlatButton(
                              textColor: Theme.of(context).accentColor,
                              onPressed: () async {
                                final playlistDB = Provider.of<PlayListDB>(context,
                                        listen: false);
                                await playlistDB.clear();
                                playlistDB.showToast('Done', context);
                                Navigator.pop(context);
                              },
                              child: Text('Continue'),
                            )
                          ],
                        );
                      });
                },
              ),
              ListTile(
                leading: Icon(Icons.info_outline),
                title: Text(
                  'About',
                  style: listStyle,
                ),
                subtitle: Text(
                  'About vybe player',
                  style: listStyle.copyWith(
                    fontSize: Config.textSize(context, 3),
                  ),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AboutDialog(
                        applicationName: 'Vybe player',
                        applicationVersion: '2.0',
                        applicationIcon: Container(
                          width: Config.xMargin(context, 20),
                          height: Config.yMargin(context, 15),
                          child: Image(
                            image: AssetImage('images/logo.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
