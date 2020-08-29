import 'package:flutter/material.dart';
import 'package:musicPlayer/components/createPlayList.dart';
import 'package:musicPlayer/components/customButton.dart';
import 'package:musicPlayer/models/Provider.dart';
import 'package:musicPlayer/models/config.dart';
import 'package:musicPlayer/models/playListDB.dart';
import 'package:musicPlayer/models/songController.dart';
import 'package:musicPlayer/screens/nowPlaying.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayList extends StatefulWidget {
  final String playListName;
  final List songList;
  PlayList(this.playListName, this.songList);
  @override
  _PlayListState createState() => _PlayListState();
}

class _PlayListState extends State<PlayList> {
  bool isPlaying = false;
  List allSongs;
  List searchList = [];
  double padding = 10.0;
  bool isSearching = false;
  TextEditingController input = TextEditingController();
  FocusNode focusNode = FocusNode();

  void search(String input) {
    searchList.clear();
    searchList.addAll(widget.songList);
    setState(() {
      searchList.retainWhere((element) =>
          element['title'].toLowerCase().contains(input.toLowerCase()));
    });
  }

  void resetSearch() {
    setState(() {
      input.clear();
      searchList.clear();
      searchList.addAll(widget.songList);
    });
  }

  @override
  void initState() {
    isPlaying = Provider.of<SongController>(context, listen: false).isPlaying;
    allSongs = widget.songList;
    searchList.addAll(widget.songList);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.only(bottom: 80),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15, top: 30, right: 20, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      CustomButton(
                        child: Icons.arrow_back,
                        diameter: 12,
                        onPressed: () => Navigator.pop(context),
                      ),
                      isSearching
                          ? SizedBox(
                              width: Config.defaultSize(context, 55),
                              child: TextField(
                                focusNode: focusNode,
                                controller: input,
                                decoration: InputDecoration(
                                  hintText: 'search ${widget.playListName}',
                                ),
                                onChanged: (String text) {
                                  search(text);
                                },
                              ),
                            )
                          : Text(
                              widget.playListName,
                              style: TextStyle(
                                  fontSize: Config.textSize(context, 5),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Acme'),
                            ),
                      CustomButton(
                        child: isSearching ? Icons.clear : Icons.search,
                        diameter: 12,
                        onPressed: () {
                          if (isSearching) {
                            resetSearch();
                          } else {
                            FocusScope.of(context).requestFocus(focusNode);
                          }
                          setState(() {
                            isSearching = !isSearching;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 0.0,
                  thickness: 1.0,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount:
                        isSearching ? searchList.length : allSongs.length,
                    itemBuilder: (context, index) {
                      return Consumer<SongController>(
                        builder: (context, controller, child) {
                          List songList = isSearching ? searchList : allSongs;
                          // controller.allSongs = songList;
                          return AnimatedPadding(
                            duration: Duration(milliseconds: 400),
                            padding: controller.nowPlaying['path'] ==
                                        songList[index]['path'] &&
                                    controller.isPlaying
                                ? EdgeInsets.symmetric(vertical: padding)
                                : EdgeInsets.all(0),
                            child: ListTile(
                              selected: controller.nowPlaying['path'] ==
                                  songList[index]['path'],
                              onTap: () async {
                                controller.allSongs = widget.songList;
                                controller.playlistName = widget.playListName;
                                isPlaying = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => NowPlaying(
                                            currentSong: songList[index],
                                            isPlaying: isPlaying,
                                          )),
                                );
                                isSearching = false;
                                resetSearch();
                                setState(() {
                                  isPlaying ? padding = 10.0 : padding = 0.0;
                                });
                              },
                              contentPadding: EdgeInsets.only(right: 20),
                              leading: PopupMenuButton(
                                icon: Icon(
                                  Icons.more_vert,
                                  size: Config.xMargin(context, 6),
                                ),
                                itemBuilder: (context) {
                                  return <PopupMenuEntry<String>>[
                                    PopupMenuItem(
                                      child: FlatButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return CreatePlayList(
                                                height: 35,
                                                width: 35,
                                                song: songList[index],
                                                isCreateNew: false,
                                              );
                                            },
                                          );
                                        },
                                        child: Text(
                                          'Add to playlist',
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ),
                                    PopupMenuItem(
                                      child: FlatButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          await buildShowDialog(context,
                                              songList, index, controller);
                                        },
                                        child: Text(
                                          widget.playListName == 'All songs' ||
                                                  widget.playListName ==
                                                      'Recently added' ||
                                                  widget.playListName ==
                                                      'Recently played'
                                              ? 'Delete song'
                                              : 'Remove song',
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ),
                                  ];
                                },
                              ),
                              title: Text(
                                songList[index]['title'],
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: Config.textSize(context, 3.5),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Acme'),
                              ),
                              subtitle: Text(
                                songList[index]['artist'],
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: Config.textSize(context, 3),
                                    fontFamily: 'Acme'),
                              ),
                              trailing: CustomButton(
                                child: controller.nowPlaying['path'] ==
                                            songList[index]['path'] &&
                                        isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                diameter: 12,
                                isToggled: controller.nowPlaying['path'] ==
                                    songList[index]['path'],
                                onPressed: () async {
                                  controller.allSongs = widget.songList;
                                  controller.playlistName = widget.playListName;
                                  await controller
                                      .playlistControlOptions(songList[index]);
                                  setState(() {
                                    isPlaying = controller.isPlaying;
                                    isPlaying ? padding = 10.0 : padding = 0.0;
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Consumer<SongController>(
              builder: (context, controller, child) {
                return GestureDetector(
                  onTap: () {
                    controller.settings(shuffle: !controller.isShuffled);
                    SharedPreferences.getInstance().then((pref) {
                      pref.setBool('shuffle', controller.isShuffled);
                      pref.setBool('repeat', controller.isRepeat);
                    });
                  },
                  child: Container(
                    height: 70,
                    margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
                    decoration: BoxDecoration(
                        color: controller.isShuffled
                            ? Theme.of(context).accentColor
                            : Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).splashColor,
                            offset: Offset(6, 6),
                            blurRadius: 10,
                          ),
                          BoxShadow(
                            color: Theme.of(context).backgroundColor,
                            offset: Offset(-6, -6),
                            blurRadius: 10,
                          ),
                        ]),
                    child: Center(
                      child: Text(
                        'SHUFFLE',
                        style: TextStyle(
                          fontSize: Config.textSize(context, 4),
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Acme',
                          color: controller.isShuffled
                              ? Colors.white
                              : Theme.of(context).textTheme.headline6.color,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ));
  }

  buildShowDialog(BuildContext context, List songList, int index,
      SongController controller) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              widget.playListName == 'All songs' ||
                      widget.playListName == 'Recently added' ||
                      widget.playListName == 'Recently played'
                  ? 'Delete "${songList[index]['title']}" from device?'
                  : 'Remove "${songList[index]['title']}" from ${widget.playListName}?',
              style: TextStyle(
                  fontSize: Config.textSize(context, 3.5),
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Acme'),
            ),
            actions: [
              FlatButton(
                  textColor: Theme.of(context).accentColor,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('No')),
              FlatButton(
                  textColor: Theme.of(context).accentColor,
                  onPressed: () async {
                    if (widget.playListName == 'All songs' ||
                        widget.playListName == 'Recently added' ||
                        widget.playListName == 'Recently played') {
                      await Provider.of<PlayListDB>(context, listen: false)
                          .removeFromDevice(songList[index]);
                      // if current song beign played is deleted its still available from libray
                      // causing craxy bugs
                      if (controller.nowPlaying == songList[index]) {
                        await controller.skip(next: true);
                        setState(() {
                          isPlaying = controller.isPlaying;
                          isPlaying ? padding = 10.0 : padding = 0.0;
                        });
                      }
                      Provider.of<ProviderClass>(context, listen: false)
                          .removeSong(songList[index]);
                      setState(() {});
                      Navigator.pop(context);
                    } else {
                      await Provider.of<PlayListDB>(context, listen: false)
                          .removeFromPlaylist(
                              widget.playListName, songList[index]);
                      setState(() {});
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Yes')),
            ],
          );
        });
  }
}
