import 'package:flutter/material.dart';
import 'package:musicPlayer/components/customButton.dart';
import 'package:musicPlayer/models/config.dart';
import 'package:musicPlayer/models/songController.dart';
import 'package:musicPlayer/screens/nowPlaying.dart';
import 'package:provider/provider.dart';

class PlayList extends StatefulWidget {
  final String playListName;
  final List songList;
  PlayList(this.playListName, this.songList);
  @override
  _PlayListState createState() => _PlayListState();
}

class _PlayListState extends State<PlayList> {
  bool isPlaying = false;
  var nowPlaying;
  List allSongs;
  List searchList = [];
  double padding = 0.0;
  bool isSearching = false;
  TextEditingController input = TextEditingController();
  FocusNode focusNode = FocusNode();

  void search(String input) {
    searchList.clear();
    searchList.addAll(widget.songList);
    setState(() {
      searchList.retainWhere((element) =>
          element['title'].toLowerCase().contains(input.toLowerCase()));
    });
  }

  void resetSearch() {
    setState(() {
      input.clear();
      searchList.clear();
      searchList.addAll(widget.songList);
    });
  }

  @override
  void initState() {
    isPlaying = Provider.of<SongController>(context, listen: false).isPlaying;
    allSongs = widget.songList;
    searchList.addAll(widget.songList);
    super.initState();
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
                      isSearching
                          ? SizedBox(
                              width: Config.defaultSize(context, 55),
                              child: TextField(
                                focusNode: focusNode,
                                controller: input,
                                decoration: InputDecoration(
                                  hintText: 'search ${widget.playListName}',
                                ),
                                onChanged: (String text) {
                                  search(text);
                                },
                              ),
                            )
                          : Text(
                              widget.playListName,
                              style: TextStyle(
                                  fontSize: Config.textSize(context, 5),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Acme'),
                            ),
                      CustomButton(
                        child: isSearching ? Icons.clear : Icons.search,
                        diameter: 12,
                        onPressed: () {
                          if (isSearching) {
                            resetSearch();
                          } else {
                            FocusScope.of(context).requestFocus(focusNode);
                          }
                          setState(() {
                            isSearching = !isSearching;
                          });
                        },
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
                    itemCount:
                        isSearching ? searchList.length : allSongs.length,
                    itemBuilder: (context, index) {
                      return Consumer<SongController>(
                        builder: (context, controller, child) {
                          List songList = isSearching ? searchList : allSongs;
                          controller.allSongs = songList;
                          return AnimatedPadding(
                            duration: Duration(milliseconds: 400),
                            padding: controller.nowPlaying == songList[index] &&
                                    controller.isPlaying
                                ? EdgeInsets.symmetric(vertical: padding)
                                : EdgeInsets.all(0),
                            child: ListTile(
                              selected:
                                  controller.nowPlaying == songList[index],
                              onTap: () async {
                                isPlaying = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => NowPlaying(
                                            currentSong: songList[index],
                                            isPlaying: isPlaying,
                                          )),
                                );
                                isSearching = false;
                                resetSearch();
                                setState(() {
                                  isPlaying ? padding = 10.0 : padding = 0.0;
                                });
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
                                songList[index]['title'],
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: Config.textSize(context, 3.5),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Acme'),
                              ),
                              subtitle: Text(
                                songList[index]['artist'],
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: Config.textSize(context, 3),
                                    fontFamily: 'Acme'),
                              ),
                              trailing: CustomButton(
                                child:
                                    controller.nowPlaying == songList[index] &&
                                            isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                diameter: 12,
                                onPressed: () async {
                                  nowPlaying = songList[index];
                                  await controller.playlistControlOptions(nowPlaying);
                                  setState(() {
                                    isPlaying = controller.isPlaying;
                                    isPlaying ? padding = 10.0 : padding = 0.0;
                                  });
                                },
                              ),
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
