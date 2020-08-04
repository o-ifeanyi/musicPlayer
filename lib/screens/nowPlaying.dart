import 'package:flutter/material.dart';
import 'package:musicPlayer/components/circleDisc.dart';
import 'package:musicPlayer/components/customButton.dart';
import 'package:musicPlayer/constants.dart';
import 'package:musicPlayer/screens/playingFrom.dart';

class NowPlaying extends StatefulWidget {
  @override
  _NowPlayingState createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying> {
  @override
  Widget build(BuildContext context) {
    var isPotrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CustomButton(
                    diameter: 50,
                    child: Icon(Icons.arrow_back),
                    isRaised: true,
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text('Now Playing', style: kHeadingText,),
                  CustomButton(
                    diameter: 50,
                    child: Icon(Icons.list),
                    isRaised: true,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PlayingFrom()),
                      );
                    },
                  ),
                ],
              ),
              isPotrait ? Expanded(child: CircleDisc()) : SizedBox(height: 10),
              Text('Music Name', style: kHeadingText),
              Text('Artist ft artist'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CustomButton(
                    diameter: 50,
                    child: Icon(Icons.favorite_border),
                    isRaised: true,
                  ),
                  CustomButton(
                    diameter: 50,
                    child: Icon(Icons.playlist_add),
                    isRaised: true,
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('1:17'),
                    Text('2:46'),
                  ],
                ),
              ),
              Slider(
                value: 50,
                onChanged: null,
                min: 0,
                max: 100,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  CustomButton(diameter: 40, child: Icon(Icons.repeat_one)),
                  CustomButton(
                    diameter: 50,
                    child: Icon(Icons.fast_rewind),
                  ),
                  CustomButton(
                    diameter: 80,
                    isRaised: true,
                    child: Icon(Icons.play_arrow),
                  ),
                  CustomButton(
                    diameter: 50,
                    child: Icon(Icons.fast_forward),
                  ),
                  CustomButton(
                    diameter: 40,
                    child: Icon(Icons.shuffle),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
