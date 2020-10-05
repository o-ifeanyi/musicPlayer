import 'package:flutter/material.dart';
import 'package:musicPlayer/components/popupButton.dart';
import 'package:musicPlayer/models/config.dart';
import 'package:musicPlayer/models/share.dart';
import 'package:musicPlayer/models/songController.dart';
import 'package:musicPlayer/screens/nowPlaying.dart';
import 'package:provider/provider.dart';

import 'customButton.dart';

class SongTile extends StatelessWidget {
  const SongTile({
    Key key,
    @required this.songList,
    @required this.canDelete,
    @required this.controller,
    @required this.index,
    @required this.resetSearch,
    @required this.playListName,
    @required this.buildShowDialog,
  }) : super(key: key);

  final List songList;
  final String playListName;
  final bool canDelete;
  final SongController controller;
  final int index;
  final Function resetSearch;
  final Function buildShowDialog;

  @override
  Widget build(BuildContext context) {
    double padding = 10.0;
    return AnimatedPadding(
      duration: Duration(milliseconds: 250),
      padding: controller.nowPlaying['path'] == songList[index]['path'] &&
              controller.isPlaying
          ? EdgeInsets.symmetric(vertical: padding)
          : EdgeInsets.all(0),
      child: Consumer<ShareClass>(
        builder: (context, share, child) {
          return ListTile(
            selected: controller.nowPlaying['path'] == songList[index]['path'],
            onTap: () async {
              if (share.isReadyToMark) {
                share.isMarked(songList[index])
                    ? share.remove(songList[index])
                    : share.add(songList[index]);
              } else {
                controller.allSongs = songList;
                controller.playlistName = playListName;
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        NowPlaying(currentSong: songList[index]),
                  ),
                );
                resetSearch();
                controller.isPlaying ? padding = 10.0 : padding = 0.0;
              }
            },
            onLongPress: () {
              share.isReadyToMark = true;
              share.add(songList[index]);
            },
            contentPadding: EdgeInsets.only(right: 20),
            leading: share.isReadyToMark
                ? Checkbox(
                    activeColor: Theme.of(context).accentColor,
                    value: share.isMarked(songList[index]),
                    onChanged: (bool newValue) {
                      newValue
                          ? share.add(songList[index])
                          : share.remove(songList[index]);
                    },
                  )
                : PopUpButton(
                    songList: songList,
                    canDelete: canDelete,
                    controller: controller,
                    index: index,
                    dialogFunction: buildShowDialog,
                  ),
            title: Text(
              songList[index]['title'],
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: Config.textSize(context, 3.5),
                fontWeight: FontWeight.w400,
              ),
            ),
            subtitle: Text(
              songList[index]['artist'],
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: Config.textSize(context, 3),
              ),
            ),
            trailing: CustomButton(
              child: controller.nowPlaying['path'] == songList[index]['path'] &&
                      controller.isPlaying
                  ? Icons.pause
                  : Icons.play_arrow,
              diameter: 12,
              isToggled:
                  controller.nowPlaying['path'] == songList[index]['path'],
              onPressed: () async {
                controller.allSongs = songList;
                controller.playlistName = playListName;
                await controller.playlistControlOptions(songList[index]);
                controller.isPlaying ? padding = 10.0 : padding = 0.0;
              },
            ),
          );
        },
      ),
    );
  }
}
