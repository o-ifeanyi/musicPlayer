import 'package:flutter/material.dart';
import 'package:musicPlayer/components/customButton.dart';
import 'package:musicPlayer/components/customCard.dart';
import 'package:musicPlayer/constants.dart';
import 'package:musicPlayer/models/Provider.dart';
import 'package:musicPlayer/models/playListDB.dart';
import 'package:musicPlayer/screens/playList.dart';
import 'package:provider/provider.dart';

class Library extends StatefulWidget {
  @override
  _LibraryState createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  void openPlaylist(String title) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlayList(title)),
    );
  }

  @override
  void initState() {
    Provider.of<ProviderClass>(context, listen: false).getAllSongs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20, top: 30, right: 20, bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Library',
                          style: kHeadingText,
                        ),
                        CustomButton(
                          diameter: 50,
                          child: Icon(Icons.search),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 0.0,
                    thickness: 1.0,
                  ),
                  SizedBox(height: 30),
                  Consumer<ProviderClass>(
                    builder: (context, provider, child) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GestureDetector(
                          onTap: () {
                            openPlaylist('All Songs');
                          },
                          child: CustomCard(
                            height: 220,
                            width: double.infinity,
                            label: 'All Songs',
                            numOfSongs: provider.allSongs.length ?? 0,
                            child: Icon(Icons.all_inclusive),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'PlayList',
                      style: kHeadingText,
                    ),
                  ),
                  SizedBox(height: 30),
                  Consumer<PlayListDB>(
                    builder: (_, playListDB, child) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Container(
                          height: 240,
                          color: Colors.transparent,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: playListDB.playList.length,
                            itemBuilder: (_, index) {
                              return playListDB.playList[index];
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Recent',
                      style: kHeadingText,
                    ),
                  ),
                  SizedBox(height: 30),
                  Consumer<PlayListDB>(
                    builder: (_, playListDB, child) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Container(
                          height: 240,
                          color: Colors.transparent,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: playListDB.recent.length,
                            itemBuilder: (_, index) {
                              return playListDB.recent[index];
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (_) => NowPlaying()),
                  // );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  height: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Middle child',
                            style: kSubHeadingText,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text('J Cole'),
                        ],
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      CustomButton(
                        diameter: 40,
                        child: Icon(Icons.fast_rewind),
                      ),
                      CustomButton(
                        diameter: 50,
                        child: Icon(Icons.play_arrow),
                      ),
                      CustomButton(
                        diameter: 40,
                        child: Icon(Icons.fast_forward),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
