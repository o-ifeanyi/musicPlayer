import 'package:flutter/material.dart';
import 'package:musicPlayer/models/config.dart';
import 'package:musicPlayer/models/playListDB.dart';
import 'package:provider/provider.dart';

class LibraryBottomSheet extends StatelessWidget {
  LibraryBottomSheet(this.playlistName);
  final playlistName;
  final editingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    TextStyle customTextStyle = TextStyle(
      fontSize: Config.textSize(context, 3.5),
      fontWeight: FontWeight.w400,
      fontFamily: 'Acme',
    );
    return Container(
      height: Config.yMargin(context, 10),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Consumer<PlayListDB>(
        builder: (context, playlistDB, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(
                            'Rename playlist',
                            style: customTextStyle,
                          ),
                          content: TextField(
                            controller: editingController,
                            decoration: InputDecoration(
                              labelText: 'New name',
                            ),
                          ),
                          actions: [
                            FlatButton(
                              textColor: Theme.of(context).accentColor,
                              onPressed: () async {
                                String newName = editingController.text;
                                if (newName != '') {
                                  await playlistDB.editPlaylistName(
                                      playlistName, newName);
                                  Navigator.pop(context);
                                }
                              },
                              child: Text(
                                'Done',
                                style: customTextStyle,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                          'Delete "$playlistName"?',
                          style: customTextStyle,
                        ),
                        actions: [
                          FlatButton(
                            textColor: Theme.of(context).accentColor,
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel'),
                          ),
                          FlatButton(
                            textColor: Theme.of(context).accentColor,
                            onPressed: () async {
                              await playlistDB.deletePlaylist(playlistName);
                              Navigator.pop(context);
                            },
                            child: Text('Continue'),
                          )
                        ],
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
