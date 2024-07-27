import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final String text;
  final void Function()? tap;
  final Color? color;
  final Color? textColor;
  final double fontSize;
  final double? height;
  final double? width;

  const ButtonWidget({super.key,required this.text,required this.tap,this.width,this.height,this.fontSize = 20,this.color,this.textColor});

  dynamic hasWidthHeight(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: tap,
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: (color != null) ? color : Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(25),
              child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                      color: textColor
                  )
              )
            ),
          )
        ]
    );
  }

  dynamic hasWidth(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: tap,
            child: Container(
              width: width,
              decoration: BoxDecoration(
                color: (color != null) ? color : Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(25),
              child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                      color: textColor
                  )
              )
            ),
          )
        ]
    );
  }

  dynamic hasHeight(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: tap,
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: (color != null) ? color : Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(25),
              child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                      color: textColor
                  )
              ),
            ),
          )
        ]
    );
  }

  @override
  Widget build(BuildContext context) {
    if(width != null && height != null) {
      return hasWidthHeight(context);
    }else if(width != null && height == null) {
      return hasWidth(context);
    }else if(width == null && height != null) {
      return hasHeight(context);
    }

    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: tap,
            child: Container(
              decoration: BoxDecoration(
                color: (color != null) ? color : Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(25),
              child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                      color: textColor
                    )
                  )
              ),
            ),
        ]
    );
  }

}