import 'package:flutter/material.dart';
import 'package:musicPlayer/models/config.dart';
import 'package:musicPlayer/models/songController.dart';
import 'package:share/share.dart';
import 'createPlayList.dart';

class PopUpButton extends StatelessWidget {
  PopUpButton({
    @required this.songList,
    @required this.canDelete,
    @required this.index,
    @required this.controller,
    @required this.dialogFunction,
  });

  final List songList;
  final bool canDelete;
  final SongController controller;
  final Function dialogFunction;
  final int index;

  @override
  Widget build(BuildContext context) {
    TextStyle customTextStyle = TextStyle(
        fontSize: Config.textSize(context, 3.5),
        fontWeight: FontWeight.w400,
        fontFamily: 'Acme');

    return PopupMenuButton(
      icon: Icon(
        Icons.more_vert,
        size: Config.xMargin(context, 6),
      ),
      itemBuilder: (context) {
        return <PopupMenuEntry<ListTile>>[
          PopupMenuItem(
            child: ListTile(
              dense: true,
              trailing: Icon(Icons.playlist_add),
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
                      songs: [songList[index]],
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
              trailing: Icon(canDelete ? Icons.delete : Icons.remove),
              onTap: () async {
                Navigator.pop(context);
                await dialogFunction(context, songList, index, controller);
              },
              title: Text(
                canDelete ? 'Delete song' : 'Remove song',
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
                final RenderBox box = context.findRenderObject();
                Navigator.pop(context);
                await Share.shareFiles([songList[index]['path']],
                    subject: songList[index]['title'],
                    sharePositionOrigin:
                        box.localToGlobal(Offset.zero) & box.size);
              },
            ),
          )
        ];
      },
    );
  }
}