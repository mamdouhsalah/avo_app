import 'package:avo_app/app/core/models/pharmacy_model.dart';
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
import 'package:avo_app/app/core/shared/bestpharmacy_card.dart';
import 'package:avo_app/app/core/Language/locale_keys.g.dart';
import 'package:avo_app/app/core/shared/loading_indicator_widget.dart';
import 'package:avo_app/app/core/shared/error_feedback_widget.dart';
import 'package:avo_app/app/core/services/auth_service.dart';

class AllPharmaciesScreen extends StatefulWidget {
  const AllPharmaciesScreen({super.key});

  @override
  State<AllPharmaciesScreen> createState() => _AllPharmaciesScreenState();
}

class _AllPharmaciesScreenState extends State<AllPharmaciesScreen> {
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
          LocaleKeys.home_best_pharmacies.tr(), // Using "Best Pharmacies" or "All Pharmacies" if available
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
            final filteredPharmacies = homeState.bestPharmacies.where((pharmacy) {
              final query = _searchQuery.toLowerCase();
              return pharmacy.name.toLowerCase().contains(query) ||
                  pharmacy.type.toLowerCase().contains(query);
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
                    child: filteredPharmacies.isEmpty
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
                                itemCount: filteredPharmacies.length,
                                itemBuilder: (context, index) {
                                  final pharmacy = filteredPharmacies[index];
                                  final isFav = context.read<FavoriteCubit>().isFavoritePharmacy(pharmacy.id);
                                  
                                  final updatedPharmacy = pharmacy.copyWith(isFavorite: isFav);

                                  return BestPharmacyCard(
                                    key: ValueKey(pharmacy.id),
                                    pharmacy: updatedPharmacy,
                                    onFavoriteToggle: () {
                                      if (patientId.isNotEmpty) {
                                        context.read<FavoriteCubit>().toggleFavoritePharmacy(patientId, pharmacy.id);
                                      }
                                    },
                                    onTap: () => context.push(
                                      AppRouter.sendPrescription,
                                      extra: pharmacy.id,
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
