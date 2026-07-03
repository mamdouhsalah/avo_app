///TODO : gett all favorites not just doctors
import 'package:avo_app/app/core/Language/locale_keys.g.dart';
import 'package:avo_app/app/core/services/auth_service.dart';
import 'package:avo_app/app/features/favorite/logic/favorite_cubit.dart';
import 'package:avo_app/app/features/favorite/logic/favorite_sate.dart';
import 'package:avo_app/app/features/favorite/view/widgets/favorite_doctor_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';



class FavoriteDoctorsScreen extends StatefulWidget {
  const FavoriteDoctorsScreen({super.key});

  @override
  State<FavoriteDoctorsScreen> createState() => _FavoriteDoctorsScreenState();
}

class _FavoriteDoctorsScreenState extends State<FavoriteDoctorsScreen> {
  @override
  void initState() {
    super.initState();
    final uid = context.read<AuthService>().currentUid;
    context.read<FavoriteCubit>().getFavoriteDoctors(uid!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.favorite_myFavoriteDoctors.tr()),
      ),
      body: BlocBuilder<FavoriteCubit, FavoriteState>(
        builder: (context, state) {
          if (state is FavoriteLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FavoriteError) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(
                  color: colorScheme.error,
                  fontSize: 14.sp,
                ),
              ),
            );
          }

          if (state is FavoriteLoaded) {
            final doctors = state.favoriteDoctors;

            if (doctors.isEmpty) {
              return Center(
                child: Text(
                  LocaleKeys.favorite_noFavoriteDoctors.tr(),
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.only(bottom: 16.h),
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                return DoctorCard(doctor: doctors[index]);
              },
            );
          }

          // FavoriteInitial or any unhandled state
          return const SizedBox.shrink();
        },
      ),
    );
  }
}