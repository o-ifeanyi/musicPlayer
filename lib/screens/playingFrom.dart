import 'package:flutter/material.dart';
import 'package:musicPlayer/components/circleDisc.dart';
import 'package:musicPlayer/components/customButton.dart';
import 'package:musicPlayer/constants.dart';

class PlayingFrom extends StatefulWidget {
  @override
  _PlayingFromState createState() => _PlayingFromState();
}

class _PlayingFromState extends State<PlayingFrom> {
  @override
  Widget build(BuildContext context) {
    bool isPotrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 30, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CustomButton(
                    diameter: 50,
                    child: Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Column(
                    children: <Widget>[
                      Text('Playing From',
                          style: kHeadingText, textAlign: TextAlign.center),
                      SizedBox(height: 5),
                      Text('Playlist Name', style: kSubHeadingText),
                    ],
                  ),
                  CustomButton(
                    diameter: 50,
                    child: Icon(Icons.more_vert),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              height: isPotrait ? 250 : 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CustomButton(
                    diameter: 50,
                    child: Icon(Icons.fast_rewind),
                  ),
                  isPotrait
                      ? Expanded(child: CircleDisc())
                      : SizedBox.shrink(),
                  CustomButton(
                    diameter: 50,
                    child: Icon(Icons.fast_forward),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 15,
                itemBuilder: (context, index) {
                  return ListTile(
                    selected: index == 3 ? true : false,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    title: Text('Song name'),
                    subtitle: Text('Artist name'),
                    trailing: CustomButton(
                      diameter: 50,
                      child: Icon(index == 3 ? Icons.pause : Icons.play_arrow),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
