import 'package:flutter/material.dart';

class PhotoHero extends StatelessWidget {
  const PhotoHero({Key? key, required this.tag, required this.photo, required this.onTap, required this.width})
      : super(key: key);

  final String tag;
  final String photo;
  final VoidCallback onTap;
  final double width;

  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Hero(
        tag: tag,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Column(
              children: [
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: Image.network(photo, fit: BoxFit.cover),
                  )
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 7, horizontal: 20),
                  alignment: Alignment.center,
                  child: Text(
                    tag,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
