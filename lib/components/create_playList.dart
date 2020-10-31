import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:musicPlayer/util/config.dart';
import 'package:musicPlayer/providers/playList_database.dart';
import 'package:musicPlayer/providers/mark_songs.dart';
import 'package:musicPlayer/providers/song_controller.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class CreatePlayList extends StatefulWidget {
  CreatePlayList({this.createNewPlaylist = true, this.songs});

  final List songs; // for adding to playlist from pop up options
  final bool createNewPlaylist;

  @override
  _CreatePlayListState createState() => _CreatePlayListState();
}

class _CreatePlayListState extends State<CreatePlayList> {
  bool createNew;
  String playlistName;
  TextEditingController inputFeild = TextEditingController();
  FocusNode focusNode = FocusNode();

  void createPlaylist() {
    if (inputFeild.text != '') {
      playlistName = inputFeild.text;
      final playlistDB = Provider.of<PlayListDB>(context, listen: false);
      playlistDB.createPlaylist(playlistName);
      playlistDB.showToast('Created successfully!', context);
      inputFeild.clear();
      // true if its executed from library screen
      // false if executed from any other screen (add to playlist)
      if (widget.createNewPlaylist) {
        Navigator.pop(context);
      } else {
        setState(() {
          createNew = false;
        });
      }
    } else {
      // keeps the keyboard open
      FocusScope.of(context).requestFocus(focusNode);
    }
  }

  @override
  void initState() {
    createNew = widget.createNewPlaylist;
    super.initState();
  }

  @override
  void deactivate() {
    playlistName = null;
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    Size viewsSize = MediaQuery.of(context).size;
    TextStyle textStyle = TextStyle(
      fontSize: Config.textSize(context, 4),
      fontWeight: FontWeight.w400,
    );

    final keyboard = FocusScope.of(context);
    createNew && !keyboard.hasPrimaryFocus
        ? keyboard.requestFocus(focusNode)
        : keyboard.unfocus();

    return Container(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      height: orientation == Orientation.portrait
          ? viewsSize.height
          : viewsSize.width,
      width: orientation == Orientation.portrait
          ? viewsSize.width
          : viewsSize.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Material(
            elevation: 6.0,
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              height: Config.yMargin(context, 30),
              width: Config.yMargin(context, 35),
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Consumer<PlayListDB>(
                builder: (context, playlistDB, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        createNew ? 'New playlist' : 'Add to playlist',
                        style: textStyle,
                      ),
                      createNew
                          ? Expanded(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextField(
                                    controller: inputFeild,
                                    focusNode: focusNode,
                                    maxLength: 14,
                                    maxLengthEnforced: true,
                                    keyboardType: TextInputType.name,
                                    textCapitalization: TextCapitalization.sentences,
                                    textInputAction: TextInputAction.done,
                                    decoration: InputDecoration(
                                      labelText: 'Name',
                                      labelStyle: textStyle,
                                    ),
                                    onSubmitted: (_) => createPlaylist(),
                                  ),
                                ],
                              ),
                            )
                          : Expanded(
                              child: ListView.builder(
                                itemCount: playlistDB.playList.length,
                                itemBuilder: (context, index) {
                                  // create playlist is at index 0
                                  return index > 0 &&
                                          index < playlistDB.playList.length
                                      ? FlatButton(
                                          onPressed: () async {
                                            widget.songs.forEach((song) async {
                                              await playlistDB.addToPlaylist(
                                                playlistDB.playList[index]
                                                    ['name'],
                                                song,
                                              );
                                              if (playlistDB.playList[index]
                                                      ['name'] ==
                                                  'Favourites') {
                                                Provider.of<SongController>(
                                                        context,
                                                        listen: false)
                                                    .setFavourite(song);
                                              }
                                            });
                                            playlistDB.showToast(
                                                'Done', context);
                                            Provider.of<MarkSongs>(context,
                                                    listen: false)
                                                .reset(notify: true);
                                            Navigator.pop(context);
                                          },
                                          // index zero is create playlist
                                          child: Text(
                                            playlistDB.playList[index]['name'],
                                            style: textStyle,
                                          ),
                                        )
                                      : SizedBox.shrink();
                                },
                              ),
                            ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FlatButton(
                            textColor: Theme.of(context).accentColor,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Cancel',
                              style: textStyle,
                            ),
                          ),
                          createNew
                              ? FlatButton(
                                  textColor: Theme.of(context).accentColor,
                                  onPressed: createPlaylist,
                                  child: Text(
                                    'Create playlist',
                                    style: textStyle,
                                  ),
                                )
                              : FlatButton(
                                  textColor: Theme.of(context).accentColor,
                                  onPressed: () {
                                    setState(() {
                                      createNew = true;
                                    });
                                  },
                                  child: Text(
                                    'New playlist',
                                    style: textStyle,
                                  ),
                                ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
