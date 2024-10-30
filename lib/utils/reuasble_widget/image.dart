import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget showImage(double radius, ImageProvider provider) {
  return radius == 0.0
      ? CircleAvatar(
          backgroundColor: Colors.blue[300],
          backgroundImage: provider,
        )
      : CircleAvatar(
          radius: radius,
          backgroundColor: Colors.blue[300],
          backgroundImage: provider,
        );
}

Widget showIcon(double size, Color iconcolor, IconData icon, double radius,
    Color backgroundcolor) {
  return size == 0.0
      ? CircleAvatar(
          radius: radius,
          backgroundColor: backgroundcolor,
          child: Icon(
            icon,
            color: iconcolor,
          ),
        )
      : CircleAvatar(
          radius: radius,
          backgroundColor: backgroundcolor,
          child: Icon(
            icon,
            color: iconcolor,
            size: size,
          ),
        );
}

Widget getImage(double height, double width, String url, double errorimagesize,
    String errorUrl, BoxShape shape, BuildContext context) {
  return CachedNetworkImage(
    imageUrl: url,
    fit: BoxFit.cover,
    height: height,
    width: width,
    imageBuilder: (context, imageProvider) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: shape,
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
        ),
      ),
    ),
    errorWidget: (context, url, error) => Image.asset(errorUrl,
        height: errorimagesize, width: errorimagesize, fit: BoxFit.cover),
    placeholder: (context, url) => Image.asset(errorUrl,
        height: errorimagesize, width: errorimagesize, fit: BoxFit.cover),
  );
}

