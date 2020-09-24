import 'package:flutter/material.dart';
import 'package:musicPlayer/components/createPlayList.dart';
import 'package:musicPlayer/models/config.dart';
import 'package:musicPlayer/models/share.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class PlaylistOptions extends StatelessWidget {
  PlaylistOptions(this.playlistName, this.canDelete);
  final playlistName;
  final bool canDelete;
  final editingController = TextEditingController();

  List<String> getPaths(ShareClass share) {
    List<String> paths = [];
    share.markedSongs.forEach((element) => paths.add(element['path']));
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
      child: Consumer<ShareClass>(
        builder: (context, share, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${share.markedSongs.length}\nselected',
                style: customTextStyle,
              ),
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () async {
                  final RenderBox box = context.findRenderObject();
                  final paths = getPaths(share);
                  await Share.shareFiles(paths,
                      sharePositionOrigin:
                          box.localToGlobal(Offset.zero) & box.size);
                  share.reset(notify: true);
                },
              ),
              IconButton(
                icon: Icon(Icons.playlist_add),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return CreatePlayList(
                        height: 35,
                        width: 35,
                        songs: share.markedSongs,
                        isCreateNew: false,
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
