import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final String text;
  final void Function()? tap;
  final double width;

  const ButtonWidget({super.key,required this.width,required this.text,required this.tap});

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: tap,
            child: Container(
              width: width,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(25),
              child: Text(text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 20)
              ),
            ),
          )
        ]
    );
  }

}