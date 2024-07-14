import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/userData.dart';
import '../widgets/buttonWidget.dart';

class ImageWidget extends StatelessWidget {
  final String url;
  final double height;

  const ImageWidget({super.key,required this.url,required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
          height: height,
          child: CachedNetworkImage(
            imageUrl: url,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        );

  }

}