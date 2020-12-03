import 'package:flutter/material.dart';
import 'package:musicPlayer/components/custom_button.dart';
import 'package:musicPlayer/components/playlist_options.dart';
import 'package:musicPlayer/components/song_tile.dart';
import 'package:musicPlayer/models/song.dart';
import 'package:musicPlayer/providers/all_songs.dart';
import 'package:musicPlayer/util/config.dart';
import 'package:musicPlayer/providers/playList_database.dart';
import 'package:musicPlayer/providers/mark_songs.dart';
import 'package:musicPlayer/providers/song_controller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayList extends StatefulWidget {
  static const String pageId = '/playlist';
  final String playListName;
  PlayList({this.playListName});
  @override
  _PlayListState createState() => _PlayListState();
}

class _PlayListState extends State<PlayList> {
  List<Song> allSongs;
  List<Song> searchList;
  bool isSearching = false;
  bool canDelete = false;
  TextEditingController input = TextEditingController();
  FocusNode focusNode = FocusNode();

  void search(String input) {
    searchList.clear();
    searchList = List.from(allSongs);
    setState(() {
      searchList.retainWhere((element) =>
          element.title.toLowerCase().contains(input.toLowerCase()) ||
          element.artist.toLowerCase().contains(input.toLowerCase()));
    });
  }

  void resetSearch() {
    setState(() {
      isSearching = false;
      input.clear();
      searchList.clear();
      searchList = List.from(allSongs);
    });
  }

  List<Song> getSongs() {
    switch (widget.playListName) {
      case ('All songs'):
        return Provider.of<ProviderClass>(context, listen: false).allSongs;
        break;
      case ('Recently added'):
        return Provider.of<ProviderClass>(context, listen: false).recentlyAdded;
        break;
      case ('Recently played'):
        return Provider.of<PlayListDB>(context, listen: false).recentList;
        break;
      default:
        final playlistdb = Provider.of<PlayListDB>(context, listen: false);
        final playlist = playlistdb.playList
            .firstWhere((element) => element['name'] == widget.playListName);
        return playlistdb.extract(playlist['songs']);
    }
  }

  @override
  void initState() {
    allSongs = getSongs();
    searchList = List.from(allSongs);
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
                    child: RefreshIndicator(
                      backgroundColor: Theme.of(context).dialogBackgroundColor,
                      onRefresh: () async {
                        setState(() {
                          allSongs = getSongs();
                        });
                        await Future.delayed(Duration(seconds: 1));
                        return;
                      },
                      child: allSongs.isNotEmpty
                          ? ListView.builder(
                              itemCount: isSearching
                                  ? searchList.length
                                  : allSongs.length,
                              itemBuilder: (context, index) {
                                List<Song> songList =
                                    isSearching ? searchList : allSongs;
                                return SongTile(
                                  index: index,
                                  allSongs: allSongs,
                                  songList: songList,
                                  playListName: widget.playListName,
                                  resetSearch: resetSearch,
                                  canDelete: canDelete,
                                  buildShowDialog: buildShowDialog,
                                );
                              },
                            )
                          : SizedBox.expand(),
                    ),
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

  buildShowDialog(BuildContext context, Song song) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            canDelete
                ? 'Delete "${song.title}" from device?'
                : 'Remove "${song.title}" from ${widget.playListName}?',
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
                  final controller =
                      Provider.of<SongController>(context, listen: false);
                  if (canDelete) {
                    await playlistDB.removeFromDevice(song);
                    playlistDB.showToast('Delete successful!', context);
                    // if current song beign played is deleted its still available from libray
                    // causing craxy bugs
                    if (controller.nowPlaying?.path == song.path) {
                      await controller.skip(next: true);
                    }
                    setState(() {
                      Provider.of<ProviderClass>(context, listen: false)
                          .removeSong(song);
                      allSongs = getSongs();
                    });
                    Navigator.pop(context);
                  } else {
                    await playlistDB.removeFromPlaylist(
                        widget.playListName, song);
                    playlistDB.showToast('Removed successfully!', context);
                    setState(() {
                      allSongs = getSongs();
                    });
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
