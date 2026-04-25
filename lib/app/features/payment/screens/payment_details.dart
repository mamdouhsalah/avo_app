import 'package:avo_app/app/core/constants/app_svg.dart';
import 'package:avo_app/app/core/shared/main_button.dart';
import 'package:avo_app/app/features/payment/screens/widgets/build_input_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class PaymentDetails extends StatelessWidget {
  const PaymentDetails({super.key});

  @override
  Widget build(BuildContext context) {

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Details'),
      ),
      body: Padding(
        padding:  EdgeInsets.all(16.0.w),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Text('Payment Details' ,style: TextStyle(fontSize: 20.sp , color: colorScheme.onSurface ,fontWeight: FontWeight.w500),),
             
            SizedBox(height: 32.h,),

            // name on card
            Text('Name on Card' , style: TextStyle(fontSize: 16.sp , color: colorScheme.onSurface),),
            SizedBox(height: 16.h,),
            TextField(
              decoration: buildInputDecoration(context: context, hint: 'Enter name on card' ),
            ),
          
          SizedBox(height: 24.h,),

          // name on card
            Text('Number on Card' , style: TextStyle(fontSize: 16.sp , color: colorScheme.onSurface),),
            SizedBox(height: 16.h,),
            TextField(
              decoration: buildInputDecoration(context: context, hint: '00 00 00 00 00' , svgPath: AppSvg.visa ),
            ),
           
           SizedBox(height: 24.h,),

          SizedBox( // solved the problem of rows inside colomn
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Expiry
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(
              'Expiry',
              style: TextStyle(
                fontSize: 12.sp,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              decoration: buildInputDecoration(
                context: context,
                hint: 'MM / YY',
              ),
            ),
          ],
        ),
      ),

      SizedBox(width: 16.w),

      /// CVV
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CVV',
              style: TextStyle(
                fontSize: 12.sp,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              decoration: buildInputDecoration(
                context: context,
                hint: '000',
              ),
              obscureText: true,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
       SizedBox(height: 195.h,),
       
       // total payment and price 
       Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total Payment :' , style: TextStyle(fontSize: 20 , color: Colors.grey),),
          Text("\$25.00" , style: TextStyle(fontSize: 20 , color: colorScheme.onSurface))
        ],
       ),
       SizedBox(height: 16,),
       // continue button
       Center(child: MainButton(text: 'Continue', onPressed: (){} , width: 342, height: 48,))
  ],
  ),
),
);
  }
}
