import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class DisplayImage extends StatelessWidget {
  final String url;

  const DisplayImage({@required this.url});

  @override
  Widget build(BuildContext context) {
    try {
      if (url != null)
        return FadeInImage.memoryNetwork(
          placeholder: kTransparentImage,
          image: url,
        );
      else
        return Image.memory(kTransparentImage);
    } catch (_) {
      return Image.memory(kTransparentImage);
    }
  }
}
