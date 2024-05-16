import 'package:flutter/material.dart';

class ExpandedButtonWidget extends StatelessWidget {
  final String text;
  final void Function()? tap;

  const ExpandedButtonWidget({super.key,required this.text,required this.tap});

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
          )
        ]
    );
  }

}