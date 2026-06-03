import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAvatar extends StatelessWidget {
  final String? imageUrl;
  final double? size;
  final double? radius;
  final Color? backgroundColor;
  final Color? borderColor;

  const CustomAvatar({
    super.key,
    this.imageUrl,
    this.size,
    this.radius,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double avatarSize = size ?? 48.r;

    final Color bgColor =
        backgroundColor ?? theme.colorScheme.primary.withOpacity(0.1);

    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 3.w)
            : null,
      ),
      child: ClipOval(
        child: _buildImageContent(theme, avatarSize),
      ),
    );
  }

  Widget _buildImageContent(ThemeData theme, double size) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildDefaultIcon(theme, size);
    }

    if (imageUrl!.startsWith('http') || imageUrl!.startsWith('https')) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultIcon(theme, size);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: 20.w,
              height: 20.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
          );
        },
      );
    }

    return Image.asset(
      imageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildDefaultIcon(theme, size);
      },
    );
  }

  Widget _buildDefaultIcon(ThemeData theme, double size) {
    return Icon(
      Icons.person,
      size: size * 0.55,
      color: theme.colorScheme.primary,
    );
  }
}
