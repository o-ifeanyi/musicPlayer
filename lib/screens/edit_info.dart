import 'package:flutter/material.dart';
import 'package:musicPlayer/components/custom_button.dart';
import 'package:musicPlayer/components/edit_info_image.dart';
import 'package:musicPlayer/models/http_exception.dart';
import 'package:musicPlayer/models/song.dart';
import 'package:musicPlayer/providers/all_songs.dart';
import 'package:musicPlayer/providers/playList_database.dart';
import 'package:musicPlayer/services/song_info.dart';
import 'package:musicPlayer/util/config.dart';
import 'package:provider/provider.dart';

class EditInfo extends StatefulWidget {
  static const String pageId = '/editInfo';
  final Song song;

  EditInfo({this.song});
  @override
  _EditInfoState createState() => _EditInfoState();
}

class _EditInfoState extends State<EditInfo> {
  final _formKey = GlobalKey<FormState>();
  // final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _trackNameController = TextEditingController();
  final _artistNameController = TextEditingController();
  final _albumNameController = TextEditingController();
  final _yearController = TextEditingController();
  final _genreController = TextEditingController();
  String _title;
  String _artist;
  String _imagePath;
  bool _isLoading = false;

  void _setImage(String path) {
    _imagePath = path;
  }

  @override
  void initState() {
    super.initState();
    _title = widget.song.title;
    _artist = widget.song.artist;
    _trackNameController.text = widget.song.title;
    _artistNameController.text = widget.song.artist;
    _albumNameController.text = widget.song.album;
    _yearController.text = widget.song.year;
    _genreController.text = widget.song.genre;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 30, bottom: 20, left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      CustomButton(
                        diameter: 12,
                        child: Icons.arrow_back,
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                      ),
                      CustomButton(
                        diameter: 12,
                        child: Icons.done,
                        onPressed: () async {
                          final isValid = _formKey.currentState.validate();
                          if (!isValid) {
                            return;
                          }
                          final newSong = Song(
                            path: widget.song.path,
                            title: _trackNameController.text,
                            artist: _artistNameController.text,
                            album: _albumNameController.text,
                            genre: _genreController.text,
                            year: _yearController.text,
                            dateAdded: widget.song.dateAdded,
                          );
                          await Provider.of<ProviderClass>(context,
                                  listen: false)
                              .editSongInfo(
                            context,
                            newSong,
                            imagePath: _imagePath,
                          );
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 0.0,
                  thickness: 1.0,
                  color: Theme.of(context).dividerColor,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      SizedBox(height: Config.yMargin(context, 2)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          EditInfoImage(widget.song.path, _setImage),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _title,
                                  softWrap: true,
                                  style: TextStyle(
                                    fontSize: Config.textSize(context, 5),
                                  ),
                                ),
                                Text(
                                  _artist,
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: Config.yMargin(context, 2)),
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () async {
                          // title and artist is required to make the search
                          final isValid = _formKey.currentState.validate();
                          if (!isValid) {
                            return;
                          }
                          setState(() {
                            _isLoading = true;
                          });
                          try {
                            final songInfo =
                                await SongInfo.getSongInfo(_title, _artist);
                            setState(() {
                              _title = songInfo['title'];
                              _artist = songInfo['artist'];
                              _trackNameController.text = songInfo['title'];
                              _artistNameController.text = songInfo['artist'];
                              _albumNameController.text = songInfo['album'];
                              _genreController.text = songInfo['genre'];
                              _yearController.text = songInfo['year'];
                            });
                          } on CustomException catch (err) {
                            final playlistDB =
                                Provider.of<PlayListDB>(context, listen: false);
                            playlistDB.showToast(err.message, context,
                                isSuccess: false);
                          } finally {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          child: _isLoading
                              ? CircularProgressIndicator(
                                  strokeWidth: 2,
                                )
                              : Text('Fetch song info'),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).scaffoldBackgroundColor,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Theme.of(context).splashColor,
                                offset: Offset(5, 5),
                                blurRadius: 10,
                                spreadRadius: 1.0,
                              ),
                              BoxShadow(
                                color: Theme.of(context).backgroundColor,
                                offset: Offset(-5, -5),
                                blurRadius: 10,
                                spreadRadius: 1.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: Config.yMargin(context, 2)),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _trackNameController,
                              decoration:
                                  InputDecoration(labelText: 'Track Name'),
                              onChanged: (val) {
                                setState(() {
                                  _title = val;
                                });
                              },
                              validator: (val) {
                                if (val.isEmpty) {
                                  return 'This field should not be empty';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: _artistNameController,
                              decoration:
                                  InputDecoration(labelText: 'Artist Name'),
                              onChanged: (val) {
                                setState(() {
                                  _artist = val;
                                });
                              },
                              validator: (val) {
                                if (val.isEmpty) {
                                  return 'This field should not be empty';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: _albumNameController,
                              decoration:
                                  InputDecoration(labelText: 'Album Name'),
                            ),
                            TextFormField(
                              controller: _yearController,
                              decoration: InputDecoration(labelText: 'Year'),
                            ),
                            TextFormField(
                              controller: _genreController,
                              decoration: InputDecoration(labelText: 'Genre'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
