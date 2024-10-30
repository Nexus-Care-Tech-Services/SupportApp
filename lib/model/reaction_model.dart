import 'package:flutter/material.dart';

enum Reaction {
  like,
  love,
  happy,
  wow,
  sad,
  please,
  none,
}

class ReactionElement {
  final Reaction reaction;
  final Widget image;

  ReactionElement(
    this.reaction,
    this.image,
  );
}
