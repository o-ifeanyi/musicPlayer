import 'package:flutter/material.dart';
import 'package:musicPlayer/components/customButton.dart';
import 'package:musicPlayer/constants.dart';

class PlayList extends StatefulWidget {
  final String playListName;
  PlayList(this.playListName);
  @override
  _PlayListState createState() => _PlayListState();
}

class _PlayListState extends State<PlayList> {
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
                          isRaised: true,
                          child: Icon(Icons.arrow_back),
                          diameter: 50,
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          widget.playListName,
                          style: kHeadingText,
                        ),
                        CustomButton(
                          isRaised: true,
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
                      itemCount: 15,
                      itemBuilder: (context, index) {
                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                          leading: CustomButton(
                            child: Text('${index + 1}'),
                            diameter: 25,
                          ),
                          title: Text(
                            'Music Title',
                            style: kSubHeadingText,
                          ),
                          subtitle: Text('artist name'),
                          trailing: CustomButton(
                            child: Icon(Icons.play_arrow),
                            diameter: 50,
                            isRaised: true,
                          ),
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
                    color: Colors.grey[300],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: Offset(6, 6),
                        blurRadius: 10,
                      ),
                      BoxShadow(
                        color: Colors.white,
                        offset: Offset(-6, -6),
                        blurRadius: 15,
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
      ),
    );
  }
}
