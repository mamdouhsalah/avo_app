import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RatingStars extends StatefulWidget {
  final int initialRating;
  final ValueChanged<int>? onRatingChanged;
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
  late int _rating;

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

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;

        return GestureDetector(
          onTap: widget.enabled
              ? () {
                  setState(() {
                    _rating = starIndex;
                  });

                  widget.onRatingChanged?.call(_rating);
                }
              : null,
          child: Padding(
            padding: EdgeInsetsDirectional.only(end: 4.w),
            child: Icon(
              starIndex <= _rating
                  ? Icons.star
                  : Icons.star_border,
              color: starIndex <= _rating
                  ? colorScheme.primary
                  : Colors.grey,
              size: 45.sp,
            ),
          ),
        );
      }),
    );
  }
}