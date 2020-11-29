import 'package:flutter/material.dart';
import 'package:musicPlayer/util/config.dart';

class CustomToast extends StatelessWidget {
  final String message;
  final bool isSuccessMsg;
  CustomToast(this.message, this.isSuccessMsg);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: isSuccessMsg
            ? Colors.green.withOpacity(0.5)
            : Colors.red.withOpacity(0.5),
      ),
      child: Wrap(
        children: [
          if (isSuccessMsg)
            Icon(
              Icons.check,
              color: Colors.white,
            ),
          SizedBox(
            width: 12.0,
          ),
          Text(
            message,
            softWrap: true,
            maxLines: 2,
            style: TextStyle(
              fontSize: Config.textSize(context, 4),
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
