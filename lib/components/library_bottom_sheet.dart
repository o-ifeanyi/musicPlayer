import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:musicPlayer/util/config.dart';
import 'package:musicPlayer/providers/playList_database.dart';
import 'package:provider/provider.dart';

class LibraryBottomSheet extends StatelessWidget {
  LibraryBottomSheet(this.playlistName);
  final playlistName;
  final editingController = TextEditingController();
  final focusNode = FocusNode();

  void rename(PlayListDB playlistDB, BuildContext context) async {
    String newName = editingController.text;
    if (newName != '' && newName != playlistName) {
      await playlistDB.editPlaylistName(playlistName, newName);
      playlistDB.showToast('Done', context);
      Navigator.pop(context);
    } else {
      print('couldnt rename playlist');
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle customTextStyle = TextStyle(
      fontSize: Config.textSize(context, 3.5),
      fontWeight: FontWeight.w400,
    );
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
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
                        // opens keyboard
                        final keyboard = FocusScope.of(context);
                        if (!keyboard.hasPrimaryFocus)
                          keyboard.requestFocus(focusNode);
                        editingController.text = playlistName;
                        return AlertDialog(
                          title: Text(
                            'Rename playlist',
                            style: customTextStyle,
                          ),
                          content: TextField(
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            focusNode: focusNode,
                            controller: editingController,
                            maxLength: 14,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: 'New name',
                            ),
                            onSubmitted: (_) => rename(playlistDB, context),
                          ),
                          actions: [
                            TextButton(
                              style: ButtonStyle(
                                textStyle: MaterialStateProperty.all(
                                  TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ),
                              onPressed: () => rename(playlistDB, context),
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
                          TextButton(
                            style: ButtonStyle(
                              textStyle: MaterialStateProperty.all(
                                TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            style: ButtonStyle(
                              textStyle: MaterialStateProperty.all(
                                TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ),
                            onPressed: () async {
                              await playlistDB.deletePlaylist(playlistName);
                              playlistDB.showToast(
                                  'Delete successful!', context);
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
