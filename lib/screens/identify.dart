import 'dart:math';
import 'package:flutter/material.dart';
import 'package:musicPlayer/components/custom_button.dart';
import 'package:musicPlayer/providers/identify_controller.dart';
import 'package:musicPlayer/util/config.dart';
import 'package:provider/provider.dart';

class Identify extends StatefulWidget {
  static const String pageId = '/identify';
  @override
  _IdentifyState createState() => _IdentifyState();
}

class _IdentifyState extends State<Identify>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  IdentifyController identifyController;

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<IdentifyController>(
          builder: (context, controller, child) {
            controller.context = context;
            controller.controller = _controller;
            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 15, top: 30, bottom: 10, right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomButton(
                          child: Icons.arrow_back,
                          diameter: 12,
                          onPressed: () => Navigator.pop(context),
                        ),
                        CustomButton(
                          child: Icons.history,
                          diameter: 12,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 1.0,
                    color: Theme.of(context).dividerColor,
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(bottom: Config.yMargin(context, 2)),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: CustomPaint(
                              painter: SearchWave(_controller, context),
                              child: Container(
                                width: Config.xMargin(context, 60),
                                height: Config.xMargin(context, 60),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: IconButton(
                              icon: Icon(
                                controller.isSearching
                                    ? Icons.clear_rounded
                                    : Icons.keyboard_voice_rounded,
                              ),
                              iconSize: Config.xMargin(context, 10),
                              color: Colors.white,
                              onPressed: controller.isSearching
                                  ? controller.stopSearch
                                  : controller.startSearch,
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: GestureDetector(
                              onTap: controller.isSearching
                                  ? controller.stopSearch
                                  : controller.startSearch,
                              child: Text(
                                controller.isSearching
                                    ? 'Tap to Cancel'
                                    : 'Tap to Listen',
                                style: TextStyle(
                                  fontSize: Config.textSize(context, 4),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class SearchWave extends CustomPainter {
  final BuildContext context;
  final Animation<double> _animation;

  SearchWave(this._animation, this.context) : super(repaint: _animation);

  void circle(Canvas canvas, Rect rect, double value) {
    double opacity = (1.0 - (value / 4.0)).clamp(0.0, 1.0);
    Color color = Theme.of(context).accentColor.withOpacity(opacity);

    double size = rect.width / 2;
    double area = size * size;
    double radius = sqrt(area * value / 4);

    final Paint paint = new Paint()..color = color;
    canvas.drawCircle(rect.center, radius, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = new Rect.fromLTRB(0.0, 0.0, size.width, size.height);

    for (int wave = 3; wave >= 0; wave--) {
      circle(canvas, rect, wave + _animation.value);
    }
  }

  @override
  bool shouldRepaint(SearchWave oldDelegate) {
    return true;
  }
}
