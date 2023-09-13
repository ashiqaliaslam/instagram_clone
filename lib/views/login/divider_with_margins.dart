import 'package:flutter/material.dart'
    show Widget, BuildContext, Column, SizedBox, Divider, StatelessWidget;

class DividerWithMargins extends StatelessWidget {
  const DividerWithMargins({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 40),
        Divider(),
        SizedBox(height: 40),
      ],
    );
  }
}
