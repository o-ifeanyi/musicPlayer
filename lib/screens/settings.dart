import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:musicPlayer/components/customButton.dart';
import 'package:musicPlayer/constants.dart';
import 'package:musicPlayer/models/Provider.dart';
import 'package:musicPlayer/models/config.dart';
import 'package:musicPlayer/models/playListDB.dart';
import 'package:musicPlayer/models/songController.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  Container buildColoredCircle(Color color1, Color color2) {
    return Container(
      height: 50,
      width: 50,
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        border: Border.all(),
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.4, 1.0],
          colors: [
            color1,
            color2,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> coloredCircles = [
      buildColoredCircle(Colors.white, Color(0xFFD71D1D)),
      buildColoredCircle(Colors.white, Colors.blueAccent),
      buildColoredCircle(Color(0xFF282C31), Colors.pinkAccent),
      buildColoredCircle(Color(0xFF282C31), Colors.deepOrange),
    ];
    TextStyle listStyle = TextStyle(
      fontSize: Config.textSize(context, 3.5),
      fontWeight: FontWeight.w400,
      fontFamily: 'Acme',
    );
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 30, bottom: 10),
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
                          fontFamily: 'Acme'),
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
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Select theme.', style: listStyle),
                            content: Container(
                              height: 60,
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
                    onTap: () {},
                    leading: Icon(Icons.image),
                    title: Text(
                      'Use album cover',
                      style: listStyle,
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
                                await Provider.of<PlayListDB>(context,
                                        listen: false)
                                    .clear();
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
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AboutDialog(
                        applicationName: 'Vybe player',
                        applicationVersion: '1.0',
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
