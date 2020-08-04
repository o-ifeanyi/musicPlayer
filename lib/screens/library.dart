import 'package:flutter/material.dart';
import 'package:musicPlayer/components/customButton.dart';
import 'package:musicPlayer/components/customCard.dart';
import 'package:musicPlayer/constants.dart';
import 'package:musicPlayer/models/Provider.dart';
import 'package:musicPlayer/screens/nowPlaying.dart';
import 'package:musicPlayer/screens/playList.dart';
import 'package:provider/provider.dart';

class Library extends StatefulWidget {
  @override
  _LibraryState createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  void openPlaylist(String title) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlayList(title)),
    );
  }

  @override
  void initState() {
    Provider.of<ProviderClass>(context, listen: false).getAllSongs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<ProviderClass>(
        builder: (context, provider, child) {
          return Scaffold(
            body: Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: ListView(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20, top: 30, right: 20, bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Library',
                              style: kHeadingText,
                            ),
                            CustomButton(
                              isRaised: true,
                              diameter: 50,
                              child: Icon(Icons.search),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 0.0,
                        thickness: 1.0,
                      ),
                      SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: CustomCard(
                          height: 220,
                          width: double.infinity,
                          label: 'All Songs',
                          numOfSongs: provider.allSongs.length ?? 0,
                          child: Icon(Icons.all_inclusive),
                          onPressed: () {
                            openPlaylist('All Songs');
                          },
                        ),
                      ),
                      SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'PlayList',
                          style: kHeadingText,
                        ),
                      ),
                      SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Container(
                          height: 240,
                          color: Colors.transparent,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 2,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  right: 20.0,
                                  bottom: 20.0,
                                ),
                                child: CustomCard(
                                  height: 240,
                                  width: 240,
                                  label: index == 0
                                      ? 'Favourites'
                                      : 'Create playlist',
                                  numOfSongs: 0,
                                  child: Icon(
                                      index == 0 ? Icons.favorite : Icons.add),
                                  onPressed: () {
                                    index == 0
                                        ? openPlaylist('Favourites')
                                        : print('create Playlist');
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Recent',
                          style: kHeadingText,
                        ),
                      ),
                      SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Container(
                          height: 240,
                          color: Colors.transparent,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 2,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  right: 20.0,
                                  bottom: 20.0,
                                ),
                                child: CustomCard(
                                  height: 240,
                                  width: 240,
                                  label: index == 0
                                      ? 'Recently added'
                                      : 'Recently played',
                                  numOfSongs: 0,
                                  child: Icon(index == 0
                                      ? Icons.playlist_add
                                      : Icons.playlist_play),
                                  onPressed: () {
                                    openPlaylist(index == 0
                                        ? 'Recently added'
                                        : 'Recently played');
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => NowPlaying()),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      color: Theme.of(context).scaffoldBackgroundColor,
                      height: 80,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Middle child',
                                style: kSubHeadingText,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text('J Cole'),
                            ],
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          CustomButton(
                            diameter: 40,
                            child: Icon(Icons.fast_rewind),
                          ),
                          CustomButton(
                            diameter: 50,
                            isRaised: true,
                            child: Icon(Icons.play_arrow),
                          ),
                          CustomButton(
                            diameter: 40,
                            child: Icon(Icons.fast_forward),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
