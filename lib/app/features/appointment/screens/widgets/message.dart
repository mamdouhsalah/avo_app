import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/Language/locale_keys.g.dart';

class Message extends StatelessWidget {
  const Message({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    final OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.r),
      borderSide:
      BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.general_message.tr(),
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface),
        ),
        SizedBox(
          height: 8.h,
        ),

        // message container
        TextField(
          minLines: 10,
          maxLines: 12,
          decoration: InputDecoration(
            hintText: LocaleKeys.appointment_write_message_hint.tr(),
            hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey),
            border: border,
            enabledBorder: border,
            focusedBorder: border,
          ),
        )
      ],
    );
  }
}