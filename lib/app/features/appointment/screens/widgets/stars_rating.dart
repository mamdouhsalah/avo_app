import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RatingStars extends StatefulWidget {
  final double initialRating;
  final ValueChanged<double>? onRatingChanged;
  final bool enabled;

  const RatingStars({
    super.key,
    this.initialRating = 0,
    this.onRatingChanged,
    this.enabled = true,
  });

  @override
  State<RatingStars> createState() => _RatingStarsState();
}

class _RatingStarsState extends State<RatingStars> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  void didUpdateWidget(covariant RatingStars oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialRating != widget.initialRating) {
      _rating = widget.initialRating;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconSize = 45.sp;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;

        IconData icon;
        // half stars
        if (_rating >= starIndex) {
          icon = Icons.star;
        } else if (_rating >= starIndex - 0.5) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          // do nothing if not enabled
          onTapDown: widget.enabled
              ? (details) {
                  final isHalf =
                      details.localPosition.dx < iconSize / 2;

                  setState(() {
                    _rating = isHalf
                        ? starIndex - 0.5
                        : starIndex.toDouble();
                  });

                  widget.onRatingChanged?.call(_rating);
                }
              : null,
          child: Padding(
            padding: EdgeInsetsDirectional.only(end: 4.w),
            child: Icon(
              icon,
              color: icon == Icons.star_border
                  ? Colors.grey
                  : colorScheme.primary,
              size: iconSize,
            ),
          ),
        );
      }),
    );
  }
}