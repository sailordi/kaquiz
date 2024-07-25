import 'package:flutter/material.dart';

class ExpandedButtonWidget extends StatelessWidget {
  final String text;
  final void Function()? tap;
  final Color?  color;
  final Color?  textColor;
  final double fontSize;

  const ExpandedButtonWidget({super.key,required this.text,required this.tap,this.color,this.textColor,this.fontSize = 20.0});

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              child:GestureDetector(
                onTap: tap,
                child: Container(
                  decoration: BoxDecoration(
                    color: (color != null) ? color : Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(25),
                  child: Text(text,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: fontSize,color: textColor)
                  ),
                ),
              )
          )
        ]
    );
  }

}