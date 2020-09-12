import 'package:flutter/material.dart';
import 'package:musicPlayer/components/createPlayList.dart';
import 'package:musicPlayer/components/customButton.dart';
import 'package:musicPlayer/components/playlistOptions.dart';
import 'package:musicPlayer/models/Provider.dart';
import 'package:musicPlayer/models/config.dart';
import 'package:musicPlayer/models/playListDB.dart';
import 'package:musicPlayer/models/share.dart';
import 'package:musicPlayer/models/songController.dart';
import 'package:musicPlayer/screens/nowPlaying.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayList extends StatefulWidget {
  final String playListName;
  final List songList;
  PlayList(this.playListName, this.songList);
  @override
  _PlayListState createState() => _PlayListState();
}

class _PlayListState extends State<PlayList> {
  List allSongs;
  List searchList = [];
  double padding = 10.0;
  bool isSearching = false;
  bool canDelete = false;
  TextEditingController input = TextEditingController();
  FocusNode focusNode = FocusNode();

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void search(String input) {
    searchList.clear();
    searchList.addAll(widget.songList);
    setState(() {
      searchList.retainWhere((element) =>
          element['title'].toLowerCase().contains(input.toLowerCase()) ||
          element['artist'].toLowerCase().contains(input.toLowerCase()));
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
    allSongs = widget.songList;
    searchList.addAll(widget.songList);
    canDelete = widget.playListName == 'All songs' ||
        widget.playListName == 'Recently added';
    super.initState();
  }

  @override
  void deactivate() {
    Provider.of<ShareClass>(context, listen: false).reset();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle customTextStyle = TextStyle(
        fontSize: Config.textSize(context, 3.5),
        fontWeight: FontWeight.w400,
        fontFamily: 'Acme');
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
                  // if songlist is empty calling [index]['path] causes it to crash
                  child: widget.songList.isNotEmpty
                      ? ListView.builder(
                          itemCount:
                              isSearching ? searchList.length : allSongs.length,
                          itemBuilder: (context, index) {
                            return Consumer<SongController>(
                              builder: (context, controller, child) {
                                List songList =
                                    isSearching ? searchList : allSongs;
                                return AnimatedPadding(
                                  duration: Duration(milliseconds: 400),
                                  padding: controller.nowPlaying['path'] ==
                                              songList[index]['path'] &&
                                          controller.isPlaying
                                      ? EdgeInsets.symmetric(vertical: padding)
                                      : EdgeInsets.all(0),
                                  child: Consumer<ShareClass>(
                                    builder: (context, share, child) {
                                      return ListTile(
                                        selected: controller.nowPlaying['path'] ==
                                            songList[index]['path'],
                                        onTap: () async {
                                          if (share.isReadyToMark) {
                                            share.isMarked(songList[index])
                                                ? share.remove(songList[index])
                                                : share.add(songList[index]);
                                            setState(() {});
                                          } else {
                                            controller.allSongs = widget.songList;
                                            controller.playlistName =
                                                widget.playListName;
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => NowPlaying(
                                                    currentSong: songList[index]),
                                              ),
                                            );
                                            isSearching = false;
                                            resetSearch();
                                            controller.isPlaying
                                                ? padding = 10.0
                                                : padding = 0.0;
                                          }
                                        },
                                        onLongPress: () {
                                          setState(() {
                                            share.isReadyToMark = true;
                                          });
                                          share.add(songList[index]);
                                        },
                                        contentPadding: EdgeInsets.only(right: 20),
                                        leading: share.isReadyToMark
                                            ? Checkbox(
                                              activeColor: Theme.of(context).accentColor,
                                                value:
                                                    share.isMarked(songList[index]),
                                                onChanged: (bool newValue) {
                                                  newValue
                                                      ? share.add(songList[index])
                                                      : share
                                                          .remove(songList[index]);
                                                  setState(() {});
                                                },
                                              )
                                            : PopupMenuButton(
                                                icon: Icon(
                                                  Icons.more_vert,
                                                  size: Config.xMargin(context, 6),
                                                ),
                                                itemBuilder: (context) {
                                                  return <PopupMenuEntry<ListTile>>[
                                                    PopupMenuItem(
                                                      child: ListTile(
                                                        dense: true,
                                                        trailing: Icon(
                                                            Icons.playlist_add),
                                                        title: Text(
                                                          'Add to playlist',
                                                          style: customTextStyle,
                                                        ),
                                                        onTap: () async {
                                                          Navigator.pop(context);
                                                          showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              return CreatePlayList(
                                                                height: 35,
                                                                width: 35,
                                                                songs:
                                                                    [songList[index]],
                                                                isCreateNew: false,
                                                              );
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    PopupMenuItem(
                                                      child: ListTile(
                                                        dense: true,
                                                        trailing: Icon(canDelete
                                                            ? Icons.delete
                                                            : Icons.remove),
                                                        onTap: () async {
                                                          Navigator.pop(context);
                                                          await buildShowDialog(
                                                              context,
                                                              songList,
                                                              index,
                                                              controller);
                                                        },
                                                        title: Text(
                                                          canDelete
                                                              ? 'Delete song'
                                                              : 'Remove song',
                                                          // textAlign: TextAlign.left,
                                                          style: customTextStyle,
                                                        ),
                                                      ),
                                                    ),
                                                    PopupMenuItem(
                                                      child: ListTile(
                                                        dense: true,
                                                        trailing: Icon(Icons.share),
                                                        title: Text(
                                                          'Share',
                                                          style: customTextStyle,
                                                        ),
                                                        onTap: () async {
                                                          final RenderBox box =
                                                              context
                                                                  .findRenderObject();
                                                          Navigator.pop(context);
                                                          await Share.shareFiles([
                                                            songList[index]['path']
                                                          ],
                                                              subject:
                                                                  songList[index]
                                                                      ['title'],
                                                              sharePositionOrigin:
                                                                  box.localToGlobal(
                                                                          Offset
                                                                              .zero) &
                                                                      box.size);
                                                        },
                                                      ),
                                                    )
                                                  ];
                                                },
                                              ),
                                        title: Text(
                                          songList[index]['title'],
                                          overflow: TextOverflow.ellipsis,
                                          style: customTextStyle,
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
                                                  controller.isPlaying
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                          diameter: 12,
                                          isToggled:
                                              controller.nowPlaying['path'] ==
                                                  songList[index]['path'],
                                          onPressed: () async {
                                            controller.allSongs = widget.songList;
                                            controller.playlistName =
                                                widget.playListName;
                                            await controller.playlistControlOptions(
                                                songList[index]);
                                            controller.isPlaying
                                                ? padding = 10.0
                                                : padding = 0.0;
                                          },
                                        ),
                                      );
                                    }
                                  ),
                                );
                              },
                            );
                          },
                        )
                      : SizedBox.expand(),
                ),
              ],
            ),
          ),
          Consumer<ShareClass>(
            builder: (context, sharee, child) {
              return Align(
                alignment: Alignment.bottomCenter,
                child: sharee.isReadyToMark
                    ? PlaylistOptions(widget.playListName, canDelete)
                    : Consumer<SongController>(
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
                                        : Theme.of(context)
                                            .textTheme
                                            .headline6
                                            .color,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              );
            }
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
              canDelete
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
                    if (canDelete) {
                      await Provider.of<PlayListDB>(context, listen: false)
                          .removeFromDevice(songList[index]);
                      // if current song beign played is deleted its still available from libray
                      // causing craxy bugs
                      if (controller.nowPlaying['path'] == songList[index]['path']) {
                        await controller.skip(next: true);
                        controller.isPlaying ? padding = 10.0 : padding = 0.0;
                      }
                      setState(() {
                        Provider.of<ProviderClass>(context, listen: false)
                          .removeSong(songList[index]);
                      });
                      Navigator.pop(context);
                    } else {
                      await Provider.of<PlayListDB>(context, listen: false)
                          .removeFromPlaylist(
                              widget.playListName, songList[index]);
                      Navigator.pop(context);
                      setState(() {});
                    }
                  },
                  child: Text('Yes')),
            ],
          );
        });
  }
}
