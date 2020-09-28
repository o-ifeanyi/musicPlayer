import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:musicPlayer/models/config.dart';
import 'package:musicPlayer/models/playListDB.dart';
import 'package:musicPlayer/models/share.dart';
import 'package:musicPlayer/models/songController.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class CreatePlayList extends StatefulWidget {
  CreatePlayList(
      {this.height, this.width, this.isCreateNew = true, this.songs});

  final double width;
  final double height;
  final List songs; // for adding to playlist from pop up options
  final bool isCreateNew;

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
      Provider.of<PlayListDB>(context, listen: false)
          .createPlaylist(playlistName);
      Navigator.pop(context);
    } else {
      print('empty feild');
    }
  }

  @override
  void initState() {
    createNew = widget.isCreateNew;
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

    return Container(
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
              height: Config.yMargin(context, widget.height),
              width: Config.yMargin(context, widget.height),
              padding: EdgeInsets.all(20),
              child: Consumer<PlayListDB>(
                builder: (context, playlistDB, child) {
                  if (createNew) {
                    // opens keyboard
                    FocusScope.of(context).requestFocus(focusNode);
                  }
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
                                    keyboardType: TextInputType.name,
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
                                  return FlatButton(
                                    onPressed: () async {
                                      widget.songs.forEach((song) async {
                                        await playlistDB.addToPlaylist(
                                          playlistDB.playList[index]['name'],
                                          song,
                                        );
                                        if (playlistDB.playList[index]
                                                ['name'] ==
                                            'Favourites') {
                                          Provider.of<SongController>(context,
                                                  listen: false)
                                              .setFavourite(song);
                                        }
                                      });
                                      Provider.of<ShareClass>(context,
                                              listen: false)
                                          .reset(notify: true);
                                      Navigator.pop(context);
                                    },
                                    child: index > 0 &&
                                            index < playlistDB.playList.length
                                        ? Text(
                                            playlistDB.playList[index]['name'],
                                            style: textStyle,
                                          )
                                        : SizedBox.shrink(),
                                  );
                                },
                              ),
                            ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FlatButton(
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
                                  onPressed: createPlaylist,
                                  child: Text(
                                    'Create playlist',
                                    style: textStyle,
                                  ),
                                )
                              : FlatButton(
                                  onPressed: () {
                                    setState(() {
                                      createNew = true;
                                    });
                                    print(createNew);
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
