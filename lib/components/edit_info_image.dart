import 'dart:io';
import 'dart:typed_data';

import 'package:audiotagger/audiotagger.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:musicPlayer/util/config.dart';

class EditInfoImage extends StatefulWidget {
  final String songPath;
  final Function setImage;

  EditInfoImage(this.songPath, this.setImage);
  @override
  _EditInfoImageState createState() => _EditInfoImageState();
}

class _EditInfoImageState extends State<EditInfoImage> {
  File _pickedImage;
  Uint8List _image;

  void _getImage() {
    Audiotagger().readArtwork(path: widget.songPath).then((value) {
      setState(() {
        value.length < 20000 ? _image = null : _image = value;
      });
    }).catchError((e) => _image = null);
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.getImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }
    print(image.path);
    setState(() {
      _pickedImage = File(image.path);
    });
    widget.setImage(image.path);
  }

  @override
  void initState() {
    super.initState();
    _getImage();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: _pickImage,
      child: Stack(
        children: [
          Container(
            height: Config.yMargin(context, 15),
            width: Config.yMargin(context, 15),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(15),
              image: _image == null && _pickedImage == null
                  ? null
                  : DecorationImage(
                      image: _pickedImage != null
                          ? FileImage(_pickedImage)
                          : MemoryImage(_image),
                      fit: BoxFit.cover
                    ),
            ),
          ),
          Container(
            alignment: Alignment.bottomLeft,
            height: Config.yMargin(context, 15),
            width: Config.yMargin(context, 15),
            padding: EdgeInsets.only(left: 10, bottom: 10),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(Icons.image),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Edit',
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
