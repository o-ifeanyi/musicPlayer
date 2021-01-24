import 'package:flutter/material.dart';
import 'package:musicPlayer/components/identied_songinfo.dart';
import 'package:musicPlayer/providers/identify_controller.dart';
import 'package:musicPlayer/util/config.dart';
import 'package:provider/provider.dart';

class HistoryBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<IdentifyController>(
      builder: (context, controller, child) {
        return Container(
          height: Config.yMargin(context, 50),
          padding: EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: controller.identifiedHistory.isEmpty
              ? Center(
                  child: Text(
                    'History is empty',
                    style: TextStyle(
                      fontSize: Config.textSize(context, 4),
                    ),
                  ),
                )
              : Column(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Divider(thickness: 6, height: 15),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Row(
                        children: [
                          Text(
                            'Swipe to delete',
                            style: TextStyle(
                              fontSize: Config.textSize(context, 3.5),
                            ),
                          ),
                          Spacer(),
                          FlatButton.icon(
                            icon: Icon(Icons.clear_rounded),
                            onPressed: () async {
                              await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(
                                    'Are you sure?',
                                    style: TextStyle(
                                      fontSize: Config.textSize(context, 3.5),
                                    ),
                                  ),
                                  actions: [
                                    FlatButton(
                                      textColor: Theme.of(context).accentColor,
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('No'),
                                    ),
                                    FlatButton(
                                      textColor: Theme.of(context).accentColor,
                                      onPressed: () async {
                                        await controller.clearHistory();
                                        Navigator.pop(context);
                                      },
                                      child: Text('Yes'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            label: Text(
                              'Clear History',
                              style: TextStyle(
                                fontSize: Config.textSize(context, 3.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: controller.identifiedHistory.length,
                          itemBuilder: (context, index) {
                            final history = controller.identifiedHistory;
                            return Dismissible(
                              key: ValueKey(history[index].title),
                              direction: DismissDirection.horizontal,
                              onDismissed: (direction) async {
                                await controller.removeHistoryItem(index);
                              },
                              confirmDismiss: (direction) {
                                return showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(
                                      'Delete "${history[index].title}" from history?',
                                      style: TextStyle(
                                        fontSize: Config.textSize(context, 3.5),
                                      ),
                                    ),
                                    actions: [
                                      FlatButton(
                                        textColor:
                                            Theme.of(context).accentColor,
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text('No'),
                                      ),
                                      FlatButton(
                                        textColor:
                                            Theme.of(context).accentColor,
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: Text('Yes'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              background: Container(
                                color: Theme.of(context).errorColor,
                                margin: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 15),
                                padding: EdgeInsets.only(right: 10),
                                child: Icon(
                                  Icons.delete,
                                  size: 40,
                                  color: Colors.white,
                                ),
                                alignment: Alignment.centerRight,
                              ),
                              child: ListTile(
                                dense: false,
                                onTap: () async {
                                  Navigator.pop(context);
                                  await showModalBottomSheet(
                                    backgroundColor: Colors.transparent,
                                    isScrollControlled: true,
                                    context: context,
                                    builder: (context) =>
                                        IdentifiedSong(history[index]),
                                  );
                                },
                                title: Text(
                                  history[index].title,
                                  style: TextStyle(
                                    fontSize: Config.textSize(context, 4.5),
                                  ),
                                ),
                                subtitle: Text(
                                  'By - ${history[index].artist}\nReleased on - ${history[index].year}',
                                  style: TextStyle(
                                    fontSize: Config.textSize(context, 3.5),
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
