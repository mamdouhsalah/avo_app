import 'package:avo_app/app/core/models/doctor_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:avo_app/app/core/routing/app_router.dart';
import 'package:avo_app/app/features/home/logic/home_cubit.dart';
import 'package:avo_app/app/features/home/logic/home_state.dart';
import 'package:avo_app/app/features/favorite/logic/favorite_cubit.dart';
import 'package:avo_app/app/features/favorite/logic/favorite_sate.dart';
import 'package:avo_app/app/core/shared/bestdoctor_card.dart';
import 'package:avo_app/app/core/Language/locale_keys.g.dart';
import 'package:avo_app/app/core/shared/loading_indicator_widget.dart';
import 'package:avo_app/app/core/shared/error_feedback_widget.dart';
import 'package:avo_app/app/core/services/auth_service.dart';

class AllDoctorsScreen extends StatefulWidget {
  const AllDoctorsScreen({super.key});

  @override
  State<AllDoctorsScreen> createState() => _AllDoctorsScreenState();
}

class _AllDoctorsScreenState extends State<AllDoctorsScreen> {
  String _searchQuery = "";
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final patientId = context.read<AuthService>().currentUid ?? "";

    // Fetch favorites on screen load if needed
    if (patientId.isNotEmpty) {
      context.read<FavoriteCubit>().getFavorites(patientId);
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          LocaleKeys.home_all_doctors.tr(),
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, homeState) {
          if (homeState is HomeLoading || homeState is HomeInitial) {
            return const Center(child: LoadingIndicatorWidget());
          }

          if (homeState is HomeError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: ErrorFeedbackWidget(
                  errorMessage: homeState.message,
                  onRetry: () {
                    context.read<HomeCubit>().loadDashboard(patientId.isNotEmpty ? patientId : '1');
                  },
                ),
              ),
            );
          }

          if (homeState is HomeLoaded) {
            final filteredDoctors = homeState.bestDoctors.where((doc) {
              final query = _searchQuery.toLowerCase();
              return doc.name.toLowerCase().contains(query) ||
                  doc.specialty.toLowerCase().contains(query) ||
                  (doc.location != null && doc.location!.toLowerCase().contains(query));
            }).toList();

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  SizedBox(height: 12.h),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                      hintText: LocaleKeys.search_page_hint.tr(),
                      hintStyle: TextStyle(
                        color: colorScheme.outlineVariant,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: colorScheme.outlineVariant,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = "";
                                });
                              },
                              icon: Icon(
                                Icons.close,
                                color: colorScheme.outlineVariant,
                              ),
                            )
                          : null,
                      filled: true,
                      fillColor: theme.cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: colorScheme.primary),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Expanded(
                    child: filteredDoctors.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 64.sp,
                                  color: colorScheme.outlineVariant,
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  LocaleKeys.search_page_no_results.tr(),
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : BlocBuilder<FavoriteCubit, FavoriteState>(
                            builder: (context, favoriteState) {
                              return ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: filteredDoctors.length,
                                itemBuilder: (context, index) {
                                  final doc = filteredDoctors[index];
                                  final isFav = context.read<FavoriteCubit>().isFavorite(doc.id);
                                  
                                  final updatedDoc = DoctorModel(
                                    id: doc.id,
                                    email: doc.email,
                                    fullName: doc.fullName,
                                    role: doc.role,
                                    gender: doc.gender,
                                    dateOfBirth: doc.dateOfBirth,
                                    phoneNumber: doc.phoneNumber,
                                    height: doc.height,
                                    weight: doc.weight,
                                    image: doc.image,
                                    isVerified: doc.isVerified,
                                    specialty: doc.specialty,
                                    clinic: doc.clinic,
                                    location: doc.location,
                                    rating: doc.rating,
                                    numberOfReviews: doc.numberOfReviews,
                                    price: doc.price,
                                    bio: doc.bio,
                                    patientsTreated: doc.patientsTreated,
                                    schedules: doc.schedules,
                                    isFavorite: isFav,
                                    ratingCount: doc.ratingCount,
                                  );

                                  return BestDoctorCard(
                                    key: ValueKey(doc.id),
                                    doctor: updatedDoc,
                                    onFavoriteToggle: () {
                                      if (patientId.isNotEmpty) {
                                        context.read<FavoriteCubit>().toggleFavorite(patientId, doc.id);
                                      }
                                    },
                                    onBook: () => context.push(
                                      AppRouter.bookPatient,
                                      extra: doc.id,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
