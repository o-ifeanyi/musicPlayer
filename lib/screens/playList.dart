import 'package:flutter/material.dart';
import 'package:musicPlayer/components/custom_button.dart';
import 'package:musicPlayer/components/playlist_options.dart';
import 'package:musicPlayer/components/song_tile.dart';
import 'package:musicPlayer/providers/all_songs.dart';
import 'package:musicPlayer/util/config.dart';
import 'package:musicPlayer/providers/playList_database.dart';
import 'package:musicPlayer/providers/mark_songs.dart';
import 'package:musicPlayer/providers/song_controller.dart';
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
  List allSongs;
  List searchList;
  bool isSearching = false;
  bool canDelete = false;
  TextEditingController input = TextEditingController();
  FocusNode focusNode = FocusNode();

  void search(String input) {
    searchList.clear();
    searchList = List.from(widget.songList);
    setState(() {
      searchList.retainWhere((element) =>
          element['title'].toLowerCase().contains(input.toLowerCase()) ||
          element['artist'].toLowerCase().contains(input.toLowerCase()));
    });
  }

  void resetSearch() {
    setState(() {
      isSearching = false;
      input.clear();
      searchList.clear();
      searchList = List.from(widget.songList);
    });
  }

  @override
  void initState() {
    allSongs = widget.songList;
    searchList = List.from(widget.songList);
    canDelete = widget.playListName == 'All songs' ||
        widget.playListName == 'Recently added';
    super.initState();
  }

  @override
  void deactivate() {
    Provider.of<MarkSongs>(context, listen: false).reset();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
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
                            : SizedBox(
                                width: Config.defaultSize(context, 55),
                                child: Text(
                                  widget.playListName,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: Config.textSize(context, 5),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                        CustomButton(
                          child: isSearching ? Icons.clear : Icons.search,
                          diameter: 12,
                          onPressed: () {
                            if (isSearching) {
                              resetSearch();
                            } else {
                              // textfield isnt built so a little delay allows setState to be called first
                              Future.delayed(Duration(milliseconds: 100))
                                  .then((value) {
                                // opens keyboard
                                FocusScope.of(context).requestFocus(focusNode);
                              });
                              setState(() {
                              isSearching = true;
                            });
                            }
                            
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
                            itemCount: isSearching
                                ? searchList.length
                                : allSongs.length,
                            itemBuilder: (context, index) {
                              return Consumer<SongController>(
                                builder: (context, controller, child) {
                                  List songList =
                                      isSearching ? searchList : allSongs;
                                  return SongTile(
                                    index: index,
                                    playListName: widget.playListName,
                                    controller: controller,
                                    songList: songList,
                                    resetSearch: resetSearch,
                                    canDelete: canDelete,
                                    buildShowDialog: buildShowDialog,
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
            Consumer<MarkSongs>(
              builder: (context, marker, child) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: marker.isReadyToMark
                      ? PlaylistOptions(widget.playListName, canDelete)
                      : Consumer<SongController>(
                          builder: (context, controller, child) {
                            return GestureDetector(
                              onTap: () {
                                controller.settings(
                                    shuffle: !controller.isShuffled);
                                SharedPreferences.getInstance().then((pref) {
                                  pref.setBool(
                                      'shuffle', controller.isShuffled);
                                  pref.setBool('repeat', controller.isRepeat);
                                });
                              },
                              child: Container(
                                height: 70,
                                margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
                                decoration: BoxDecoration(
                                    color: controller.isShuffled
                                        ? Theme.of(context).accentColor
                                        : Theme.of(context)
                                            .scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(50),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context).splashColor,
                                        offset: Offset(6, 6),
                                        blurRadius: 10,
                                      ),
                                      BoxShadow(
                                        color:
                                            Theme.of(context).backgroundColor,
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
              },
            ),
          ],
        ),
      ),
    );
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
            ),
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
                  final playlistDB =
                      Provider.of<PlayListDB>(context, listen: false);
                  if (canDelete) {
                    await playlistDB.removeFromDevice(songList[index]);
                    playlistDB.showToast('Delete successful!', context);
                    // if current song beign played is deleted its still available from libray
                    // causing craxy bugs
                    if (controller.nowPlaying['path'] ==
                        songList[index]['path']) {
                      await controller.skip(next: true);
                      // controller.isPlaying ? padding = 10.0 : padding = 0.0;
                    }
                    setState(() {
                      Provider.of<ProviderClass>(context, listen: false)
                          .removeSong(songList[index]);
                    });
                    Navigator.pop(context);
                  } else {
                    await playlistDB.removeFromPlaylist(
                        widget.playListName, songList[index]);
                    playlistDB.showToast('Removed successfully!', context);
                    setState(() {});
                    Navigator.pop(context);
                    // setstate wasnt having the desired effect until after a while
                    Future.delayed(Duration(milliseconds: 500))
                        .then((value) => setState(() {}));
                  }
                },
                child: Text('Yes')),
          ],
        );
      },
    );
  }
}
