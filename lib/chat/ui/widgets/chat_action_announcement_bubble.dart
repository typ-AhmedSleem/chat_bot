import 'package:flutter/material.dart';

class ActionAnnouncementBubble extends StatelessWidget {
  final String content;
  final Color color = const Color(0x558AD3D5);

  const ActionAnnouncementBubble({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 12,
          bottom: 15,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(6)),
            color: color,
          ),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(content),
          ),
        ),
      ),
    );
  }
}
