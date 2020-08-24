import 'package:flutter/material.dart';
import 'package:musicPlayer/components/customButton.dart';
import 'package:musicPlayer/constants.dart';
import 'package:musicPlayer/models/Provider.dart';
import 'package:musicPlayer/models/config.dart';
import 'package:musicPlayer/models/playListDB.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 10, top: 30, bottom: 10),
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
                  return SwitchListTile(
                    activeColor: Theme.of(context).accentColor,
                    title: Row(
                      children: <Widget>[
                        provider.getTheme() == kDarkTheme
                            ? Icon(Icons.remove_circle)
                            : Icon(Icons.lightbulb_outline),
                        SizedBox(
                          width: 30,
                        ),
                        Text(
                          provider.getTheme() == kDarkTheme
                              ? 'Dark Theme'
                              : 'Light Theme',
                        ),
                      ],
                    ),
                    value: provider.getTheme() == kDarkTheme,
                    onChanged: (bool newValue) async {
                      if (provider.getTheme() == kDarkTheme) {
                        provider.setTheme(kLightTheme);
                      } else {
                        provider.setTheme(kDarkTheme);
                      }
                      var pref = await SharedPreferences.getInstance();
                      pref.setBool('theme', provider.getTheme() == kDarkTheme);
                    },
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.restore),
                title: Text('Reset playlist'),
                onTap: () {
                  Provider.of<PlayListDB>(context, listen: false).clear();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
