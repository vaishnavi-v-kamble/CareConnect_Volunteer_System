
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class NetworkPhoto extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const NetworkPhoto({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(18),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        height: height,
        width: width,
        fit: fit,
        placeholder: (context, url) => Container(
          height: height,
          width: width,
          color: AppColors.mint,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(
            color: AppColors.teal,
            strokeWidth: 2,
          ),
        ),
        errorWidget: (context, url, error) => Container(
          height: height,
          width: width,
          color: AppColors.mint,
          alignment: Alignment.center,
          child: const Icon(
            Icons.volunteer_activism_rounded,
            size: 42,
            color: AppColors.teal,
          ),
        ),
      ),
    );
  }
}
