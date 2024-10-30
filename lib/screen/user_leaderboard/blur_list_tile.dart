// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:support/utils/color.dart';
import 'package:support/utils/reuasble_widget/image.dart';

class BlurredListTile extends StatelessWidget {
  const BlurredListTile({
    Key? key,
    required this.rank,
    required this.points,
    required this.name,
    required this.imageUrl,
  }) : super(key: key);

  final int rank;
  final String points;
  final String name;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.blue.shade100,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.transparent,
        ),
        child: Row(
          children: [
            Text(
              rank.toString(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xff4F5357),
              ),
            ),
            const SizedBox(width: 10),
            imageUrl == ""
                ? showIcon(0.0, colorWhite, Icons.person, 20, colorGrey)
                : showImage(
                    20,
                    NetworkImage(imageUrl),
                  ),
            const SizedBox(width: 10),
            Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xff4F5357),
              ),
            ),
            const Spacer(),
            Text(
              '${points.split(',').first.trim()} RP',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xff4F5357),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
