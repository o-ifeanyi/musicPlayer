import 'package:flutter/material.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:musicPlayer/components/createPlayList.dart';
import 'package:musicPlayer/components/customButton.dart';
import 'package:musicPlayer/components/customCard.dart';
import 'package:musicPlayer/components/libraryBottomSheet.dart';
import 'package:musicPlayer/models/Provider.dart';
import 'package:musicPlayer/models/config.dart';
import 'package:musicPlayer/models/playListDB.dart';
import 'package:musicPlayer/models/songController.dart';
import 'package:musicPlayer/screens/nowPlaying.dart';
import 'package:musicPlayer/screens/playList.dart';
import 'package:musicPlayer/screens/settings.dart';
import 'package:provider/provider.dart';
import 'package:flutter_media_notification/flutter_media_notification.dart';

class Library extends StatefulWidget {
  @override
  _LibraryState createState() => _LibraryState();
}

class _LibraryState extends State<Library> with WidgetsBindingObserver {
  SongController _controller;
  dynamic currentSong;
  void openPlaylist({String title, List songList}) {
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

  void setAllSongs(SongController controller) {
    controller.allSongs = controller.allSongs == null
        ? Provider.of<ProviderClass>(context, listen: false).allSongs
        : controller.allSongs;
    controller.playlistName =
        controller.playlistName == null ? 'All songs' : controller.playlistName;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  void showNotification() {
    _controller = Provider.of<SongController>(context, listen: false);
    if (_controller.nowPlaying['path'] != null) {
      MediaNotification.showNotification(
        title: _controller.nowPlaying['title'],
        author: _controller.nowPlaying['artist'],
        isPlaying: _controller.isPlaying,
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _controller = Provider.of<SongController>(context, listen: false);
    _controller.state = state;
    // if app comes to the foregroung hide notification
    if (state == AppLifecycleState.resumed) {
      MediaNotification.hideNotification();
    }
    //if app goes to background show notification
    if (state == AppLifecycleState.paused &&
        _controller.nowPlaying['path'] != null) {
      showNotification();
      MediaNotification.setListener('play', () => _controller.play());
      MediaNotification.setListener('pause', () => _controller.pause());
      MediaNotification.setListener('next', () async {
        await _controller.skip(next: true);
        showNotification();
      });
      MediaNotification.setListener('prev', () async {
        await _controller.skip(prev: true);
        showNotification();
      });
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await MoveToBackground.moveTaskToBack();
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Stack(
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
                            ),
                          ),
                          CustomButton(
                            diameter: 12,
                            child: Icons.settings,
                            onPressed: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Settings()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 0.0,
                      thickness: 1.0,
                      color: Theme.of(context).dividerColor,
                    ),
                    SizedBox(height: Config.yMargin(context, 3)),
                    Consumer<ProviderClass>(
                      builder: (context, provider, child) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GestureDetector(
                            onTap: () {
                              openPlaylist(
                                  title: 'All songs',
                                  songList: provider.allSongs);
                            },
                            child: CustomCard(
                              height: 30,
                              width: double.infinity,
                              label: 'All songs',
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
                        ),
                      ),
                    ),
                    Consumer<PlayListDB>(
                      builder: (_, playListDB, child) {
                        return Container(
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
                                  if (playListDB.playList[index]['name'] ==
                                      'Create playlist') {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return CreatePlayList(
                                          createNewPlaylist: true,
                                        );
                                      },
                                    );
                                  } else {
                                    openPlaylist(
                                        title: playListDB.playList[index]
                                            ['name'],
                                        songList: songList);
                                  }
                                },
                                onLongPress: () {
                                  if (index > 1) {
                                    showModalBottomSheet(
                                      enableDrag: false,
                                      context: context,
                                      builder: (context) => LibraryBottomSheet(
                                          playListDB.playList[index]['name']),
                                    );
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
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
                        ),
                      ),
                    ),
                    Consumer<PlayListDB>(
                      builder: (context, playlistDB, child) {
                        return Container(
                          height: Config.yMargin(context, 30),
                          color: Colors.transparent,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 2,
                            itemBuilder: (context, index) {
                              List recentSongList = [];
                              return GestureDetector(
                                onTap: () {
                                  recentSongList = index == 0
                                      ? Provider.of<ProviderClass>(context,
                                              listen: false)
                                          .recentlyAdded
                                      : playlistDB.recentList;
                                  openPlaylist(
                                    title: index == 0
                                        ? 'Recently added'
                                        : 'Recently played',
                                    songList: recentSongList,
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: CustomCard(
                                    height: 30,
                                    width: 30,
                                    label: index == 0
                                        ? 'Recently added'
                                        : 'Recently played',
                                    child: index == 0
                                        ? Icons.playlist_add
                                        : Icons.playlist_play,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Consumer<SongController>(
                builder: (context, controller, child) {
                  // if the list or playlist name empty (when the app is opened) use all songs
                  setAllSongs(controller);
                  currentSong = controller.nowPlaying['path'] == null
                      ? controller.lastPlayed
                      : controller.nowPlaying;
                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () {
                        if (currentSong != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  NowPlaying(currentSong: currentSong),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        color: Theme.of(context).scaffoldBackgroundColor,
                        height: Config.yMargin(context, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(
                                  width: Config.xMargin(context, 40),
                                  child: Text(
                                    currentSong == null
                                        ? 'title'
                                        : currentSong['title'],
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: Config.textSize(context, 3.5),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: Config.yMargin(context, 1),
                                ),
                                SizedBox(
                                  width: Config.xMargin(context, 40),
                                  child: Text(
                                    currentSong == null
                                        ? 'artist'
                                        : currentSong['artist'],
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: Config.textSize(context, 3),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            CustomButton(
                              diameter: 12,
                              child: Icons.skip_previous,
                              onPressed: () async {
                                if (currentSong != null) {
                                  await controller.skip(prev: true);
                                }
                              },
                            ),
                            CustomButton(
                              diameter: 15,
                              child: controller.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              isToggled: controller.isPlaying,
                              onPressed: () {
                                // if nothing is playing
                                if (controller.nowPlaying['path'] == null) {
                                  controller.setUp(currentSong);
                                } else {
                                  controller.isPlaying
                                      ? controller.pause()
                                      : controller.play();
                                }
                              },
                            ),
                            CustomButton(
                              diameter: 12,
                              child: Icons.skip_next,
                              onPressed: () async {
                                if (currentSong != null) {
                                  await controller.skip(next: true);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
