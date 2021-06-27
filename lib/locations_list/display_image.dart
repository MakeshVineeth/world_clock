import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:octo_image/octo_image.dart';

class DisplayImage extends StatelessWidget {
  final String url;

  const DisplayImage({@required this.url});

  final double size = 25.0;

  @override
  Widget build(BuildContext context) {
    try {
      if (url != null && url != '')
        return OctoImage.fromSet(
          fit: BoxFit.cover,
          image: AssetImage(url, package: 'country_icons'),
          height: size,
          width: size,
          octoSet: OctoSet.circleAvatar(
            backgroundColor: Colors.transparent,
            text: Text(''),
          ),
        );
      else
        return Image.memory(kTransparentImage);
    } catch (_) {
      return Image.memory(kTransparentImage);
    }
  }
}
