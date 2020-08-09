import 'package:flutter/material.dart';
import 'package:musicPlayer/components/customButton.dart';
import 'package:musicPlayer/models/Provider.dart';
import 'package:musicPlayer/models/config.dart';
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
  SongController player;
  var nowPlaying;
  List allSongs;

  @override
  void initState() {
    player = Provider.of<SongController>(context, listen: false);
    allSongs = Provider.of<ProviderClass>(context, listen: false).allSongs;
    super.initState();
  }

  @override
  void deactivate() {
    if (player.nowPlaying != null) {
      player.disposePlayer();
    }
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
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
                        child: Icons.arrow_back,
                        diameter: 12,
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        widget.playListName,
                        style: TextStyle(
                            fontSize: Config.textSize(context, 5),
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Acme'),
                      ),
                      CustomButton(
                        child: Icons.search,
                        diameter: 12,
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
                            selected: player.nowPlaying == allSongs[index],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NowPlaying(
                                          currentSong: allSongs[index],
                                          isPlaying: isPlaying,
                                        )),
                              );
                            },
                            contentPadding: EdgeInsets.only(right: 20),
                            leading: IconButton(
                              icon: Icon(
                                Icons.more_vert,
                                size: Config.xMargin(context, 6),
                              ),
                              onPressed: null,
                            ),
                            title: Text(
                              allSongs[index]['title'],
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: Config.textSize(context, 3.5),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Acme'),
                            ),
                            subtitle: Text(
                              allSongs[index]['artist'],
                              style: TextStyle(
                                  fontSize: Config.textSize(context, 3),
                                  fontFamily: 'Acme'),
                            ),
                            trailing: CustomButton(
                              child: player.nowPlaying == allSongs[index] &&
                                      isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              diameter: 12,
                              onPressed: () async {
                                nowPlaying = allSongs[index];
                                if (player.nowPlaying == null) {
                                  nowPlaying = allSongs[index];
                                  await player.setUp(allSongs[index], context);
                                  isPlaying = true;
                                } else if (player.nowPlaying == nowPlaying) {
                                  isPlaying ? player.pause() : player.play();
                                  setState(() {
                                    isPlaying = !isPlaying;
                                  });
                                } else if (player.nowPlaying != nowPlaying) {
                                  player.disposePlayer();
                                  nowPlaying = allSongs[index];
                                  player.setUp(allSongs[index], context);
                                  isPlaying = true;
                                }
                                setState(() {});
                              },
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
                  style: TextStyle(
                      fontSize: Config.textSize(context, 4),
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Acme'),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
