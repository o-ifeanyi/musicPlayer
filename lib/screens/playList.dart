import 'package:flutter/material.dart';
import 'package:musicPlayer/components/customButton.dart';
import 'package:musicPlayer/constants.dart';
import 'package:musicPlayer/models/Provider.dart';
import 'package:musicPlayer/models/songController.dart';
import 'package:musicPlayer/screens/nowPlaying.dart';
import 'package:provider/provider.dart';

class PlayList extends StatefulWidget {
  final String playListName;
  PlayList(this.playListName);
  @override
  _PlayListState createState() => _PlayListState();
}

class _PlayListState extends State<PlayList> {
  bool isPlaying = false;
  List allSongs;

  @override
  void initState() {
    allSongs = Provider.of<ProviderClass>(context, listen: false).allSongs;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Stack(
        children: <Widget>[
          Padding(
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
                        child: Icon(Icons.arrow_back),
                        diameter: 50,
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        widget.playListName,
                        style: kHeadingText,
                      ),
                      CustomButton(
                        child: Icon(Icons.search),
                        diameter: 50,
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 0.0,
                  thickness: 1.0,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: allSongs.length,
                    itemBuilder: (context, index) {
                      return Consumer<SongController>(
                        builder: (context, controller, child) {
                          return ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NowPlaying(
                                          currentSong: allSongs[index],
                                          isPlaying: true,
                                        )),
                              );
                            },
                            contentPadding: EdgeInsets.only(right: 20),
                            leading: IconButton(
                              icon: Icon(Icons.more_vert),
                              onPressed: null,
                            ),
                            title: Text(
                              allSongs[index]['title'],
                              overflow: TextOverflow.ellipsis,
                              style: kSubHeadingText,
                            ),
                            subtitle: Text(allSongs[index]['artist']),
                            trailing: CustomButton(
                              child: Icon(Icons.play_arrow),
                              diameter: 50,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 70,
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: Offset(6, 6),
                      blurRadius: 10,
                    ),
                    BoxShadow(
                      color: Colors.white,
                      offset: Offset(-6, -6),
                      blurRadius: 10,
                    ),
                  ]),
              child: Center(
                child: Text(
                  'SHUFFLE',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
