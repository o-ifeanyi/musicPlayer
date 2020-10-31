import 'package:flutter/material.dart';
import 'package:musicPlayer/components/create_playList.dart';
import 'package:musicPlayer/util/config.dart';
import 'package:musicPlayer/providers/mark_songs.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class PlaylistOptions extends StatelessWidget {
  PlaylistOptions(this.playlistName, this.canDelete);
  final playlistName;
  final bool canDelete;
  final editingController = TextEditingController();

  List<String> getPaths(MarkSongs marker) {
    List<String> paths = [];
    marker.markedSongs.forEach((element) => paths.add(element['path']));
    return paths;
  }

  @override
  Widget build(BuildContext context) {
    TextStyle customTextStyle = TextStyle(
      fontSize: Config.textSize(context, 3.5),
      fontWeight: FontWeight.w400,
    );
    return Container(
      height: 70,
      margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
      padding: EdgeInsets.only(left: 30, right: 10),
      decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
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
      child: Consumer<MarkSongs>(
        builder: (context, marker, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${marker.markedSongs.length}\nselected',
                style: customTextStyle,
              ),
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () async {
                  final RenderBox box = context.findRenderObject();
                  final paths = getPaths(marker);
                  await Share.shareFiles(paths,
                      sharePositionOrigin:
                          box.localToGlobal(Offset.zero) & box.size);
                  marker.reset(notify: true);
                },
              ),
              IconButton(
                icon: Icon(Icons.playlist_add),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return CreatePlayList(
                        songs: marker.markedSongs,
                        createNewPlaylist: false,
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
