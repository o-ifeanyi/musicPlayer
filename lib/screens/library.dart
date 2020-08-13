import 'package:flutter/material.dart';
import 'package:musicPlayer/components/createPlayList.dart';
import 'package:musicPlayer/components/customButton.dart';
import 'package:musicPlayer/components/customCard.dart';
import 'package:musicPlayer/models/Provider.dart';
import 'package:musicPlayer/models/config.dart';
import 'package:musicPlayer/models/playListDB.dart';
import 'package:musicPlayer/models/songController.dart';
import 'package:musicPlayer/screens/playList.dart';
import 'package:provider/provider.dart';

class Library extends StatefulWidget {
  @override
  _LibraryState createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  void openPlaylist(String title, List songList) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlayList(title, songList)),
    );
  }

  IconData getPlaylistIcon(index) {
    switch (index) {
      case 0:
        return Icons.add;
        break;
      case 1:
        return Icons.favorite_border;
        break;
      default:
        return Icons.star_border;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(bottom: 80),
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
                          style: TextStyle(
                              fontSize: Config.textSize(context, 5),
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Acme'),
                        ),
                        CustomButton(diameter: 12, child: Icons.search),
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
                            Provider.of<SongController>(context,
                                          listen: false)
                                      .allSongs = provider.allSongs;
                            openPlaylist('All Songs', provider.allSongs);
                          },
                          child: CustomCard(
                            height: 30,
                            width: double.infinity,
                            label: 'All Songs',
                            numOfSongs: provider.allSongs.length ?? 0,
                            child: Icons.all_inclusive,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: Config.yMargin(context, 3),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'PlayList',
                      style: TextStyle(
                          fontSize: Config.textSize(context, 5),
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Acme'),
                    ),
                  ),
                  Consumer<PlayListDB>(
                    builder: (_, playListDB, child) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Container(
                          height: Config.yMargin(context, 30),
                          color: Colors.transparent,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: playListDB.playList.length,
                            itemBuilder: (_, index) {
                              List songList =
                                  playListDB.playList[index]['songs'];
                              return GestureDetector(
                                onTap: () {
                                  if (index == 0) {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return CreatePlayList(
                                          height: 35,
                                          width: 35,
                                          isCreateNew: true,
                                        );
                                      },
                                    );
                                  } else {
                                    Provider.of<SongController>(context,
                                          listen: false)
                                      .allSongs = songList;
                                    openPlaylist(
                                        playListDB.playList[index]['name'],
                                        songList);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    right: 20.0,
                                    bottom: 20.0,
                                    top: 20.0,
                                  ),
                                  child: CustomCard(
                                    height: 30,
                                    width: 30,
                                    label: playListDB.playList[index]['name'],
                                    child: getPlaylistIcon(index),
                                    numOfSongs: songList?.length,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Recent',
                      style: TextStyle(
                          fontSize: Config.textSize(context, 5),
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Acme'),
                    ),
                  ),
                  Consumer<PlayListDB>(
                    builder: (_, playListDB, child) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Container(
                          height: Config.yMargin(context, 30),
                          color: Colors.transparent,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: playListDB.recent.length,
                            itemBuilder: (_, index) {
                              return GestureDetector(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    right: 20.0,
                                    bottom: 20.0,
                                    top: 20.0,
                                  ),
                                  child: CustomCard(
                                    height: 30,
                                    width: 30,
                                    label: playListDB.recent[index]['name'],
                                    child: index == 0
                                        ? Icons.playlist_add
                                        : Icons.playlist_play,
                                    numOfSongs: playListDB.recent[index]
                                        ['noOfSongs'],
                                  ),
                                ),
                              );
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
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  height: Config.yMargin(context, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Middle child',
                            style: TextStyle(
                                fontSize: Config.textSize(context, 3.5),
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Acme'),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            'J Cole',
                            style: TextStyle(
                                fontSize: Config.textSize(context, 3),
                                fontFamily: 'Acme'),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: Config.xMargin(context, 12),
                      ),
                      CustomButton(diameter: 12, child: Icons.skip_previous),
                      CustomButton(
                        diameter: 15,
                        child: Icons.play_arrow,
                        onPressed: () {
                          Provider.of<PlayListDB>(context, listen: false)
                              .clear();
                        },
                      ),
                      CustomButton(diameter: 12, child: Icons.skip_next),
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
