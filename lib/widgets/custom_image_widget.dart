import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show File;

class CustomImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final BoxFit fit;

  /// Optional widget to show when the image fails to load.
  /// If null, a default asset image is shown.
  final Widget? errorWidget;

  const CustomImageWidget({
    super.key,
    required this.imageUrl,
    this.width = 60,
    this.height = 60,
    this.fit = BoxFit.cover,
    this.errorWidget,
    String? svgPath,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;

    // Fallback if null or empty
    if (url == null || url.isEmpty) {
      return _fallbackAsset();
    }

    // If it's a network URL
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return _buildNetwork(url);
    }

    // If running on web, best effort use network (e.g., blob/asset-served urls)
    if (kIsWeb) {
      return Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, _, __) => _fallbackAsset(),
        loadingBuilder: (context, child, progress) => _placeholder(),
      );
    }

    // Otherwise, treat as local file path
    return Image.file(
      File(url),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, _, __) => _fallbackAsset(),
    );
  }

  Widget _buildNetwork(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      errorWidget: (context, _, __) => _fallbackAsset(),
      placeholder: (context, _) => _placeholder(),
    );
  }

  Widget _fallbackAsset() {
    return errorWidget ??
        Image.asset(
          "assets/images/no-image.jpg",
          fit: fit,
          width: width,
          height: height,
        );
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
