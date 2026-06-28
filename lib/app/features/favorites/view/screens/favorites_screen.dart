import 'package:avo_app/app/core/shared/bestdoctor_card.dart';
import 'package:avo_app/app/core/shared/bestpharmacy_card.dart';
import 'package:avo_app/app/features/home/logic/home_cubit.dart';
import 'package:avo_app/app/features/home/logic/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Favorites',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.outlineVariant,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(text: 'Doctors'),
              Tab(text: 'Pharmacies'),
            ],
          ),
        ),
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoaded) {
              final favoriteDoctors =
                  state.bestDoctors.where((doc) => doc.isFavorite).toList();
              final favoritePharmacies = state.bestPharmacies
                  .where((pharm) => pharm.isFavorite)
                  .toList();

              return TabBarView(
                children: [
                  // Doctors Tab
                  favoriteDoctors.isEmpty
                      ? Center(
                          child: Text(
                            'No favorite doctors yet.',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.outline,
                              fontSize: 16.sp,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(
                              vertical: 16.h, horizontal: 16.w),
                          itemCount: favoriteDoctors.length,
                          itemBuilder: (context, index) {
                            return BestDoctorCard(
                              key: ValueKey(favoriteDoctors[index].id),
                              doctor: favoriteDoctors[index],
                              onFavoriteToggle: () {},
                              onBook: () {},
                            );
                          },
                        ),

                  // Pharmacies Tab
                  favoritePharmacies.isEmpty
                      ? Center(
                          child: Text(
                            'No favorite pharmacies yet.',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.outline,
                              fontSize: 16.sp,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(
                              vertical: 16.h, horizontal: 16.w),
                          itemCount: favoritePharmacies.length,
                          itemBuilder: (context, index) {
                            return BestPharmacyCard(
                              key: ValueKey(favoritePharmacies[index].id),
                              pharmacy: favoritePharmacies[index],
                              onFavoriteToggle: () {},
                              onTap: () {},
                            );
                          },
                        ),
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
