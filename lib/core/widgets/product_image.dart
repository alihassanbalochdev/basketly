import 'package:flutter/material.dart';

/// Shows the product photo from Supabase Storage, or a large department
/// icon while there is no photo yet (or it fails to load).
class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.imageUrl,
    required this.fallbackIcon,
    required this.size,
    required this.iconColor,
  });

  final String? imageUrl;
  final IconData fallbackIcon;
  final double size;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(fallbackIcon, size: size * 0.6, color: iconColor);

    return SizedBox.square(
      dimension: size,
      child: switch (imageUrl) {
        final url? => Image.network(
            url,
            fit: BoxFit.contain,
            // The icon shows while the photo downloads, then it fades in.
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) return child;
              return Stack(
                alignment: Alignment.center,
                children: [
                  if (frame == null) fallback,
                  AnimatedOpacity(
                    opacity: frame == null ? 0 : 1,
                    duration: const Duration(milliseconds: 250),
                    child: child,
                  ),
                ],
              );
            },
            errorBuilder: (context, error, stackTrace) => Center(child: fallback),
          ),
        null => Center(child: fallback),
      },
    );
  }
}
