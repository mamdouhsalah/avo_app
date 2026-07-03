import 'package:avo_app/app/core/models/doctor_model.dart';
import 'package:avo_app/app/core/models/favorite_model.dart';
import 'package:avo_app/app/features/favorite/data/favorit_repo.dart';
import 'package:avo_app/app/features/favorite/logic/favorite_sate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoriteCubit extends Cubit<FavoriteState> {
  final FavoriteRepository _repository;

  FavoriteCubit({required FavoriteRepository repository})
      : _repository = repository,
        super(const FavoriteInitial());

  FavoriteModel? _favorites;
  List<DoctorModel> _favoriteDoctors = [];

  Future<void> getFavorites(String patientId) async {
    if (isClosed) return;

    emit(const FavoriteLoading());

    try {
      _favorites = await _repository.getFavorites(patientId);

      if (isClosed) return;

      emit(
        FavoriteLoaded(
          favorites: _favorites!,
          favoriteDoctors: _favoriteDoctors,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(FavoriteError(e.toString()));
    }
  }

  Future<void> toggleFavorite(String patientId, String doctorId) async {
    if (_favorites == null) {
      _favorites = FavoriteModel(
        patientId: patientId,
        doctorIds: {},
        pharmacyIds: {},
      );
    }
    // optimistic update — flip immediately in UI
    final current = _favorites!.isFavoriteDoctor(doctorId);
    final updatedMap = Map<String, bool>.from(_favorites!.doctorIds)
      ..[doctorId] = !current;

    _favorites = FavoriteModel(
      patientId: patientId,
      doctorIds: updatedMap,
      pharmacyIds: _favorites!.pharmacyIds,
    );

    if (isClosed) return;

    emit(
      FavoriteLoaded(
        favorites: _favorites!,
        favoriteDoctors: _favoriteDoctors,
      ),
    );

    try {
      await _repository.toggleFavorite(
        patientId,
        doctorId,
        !current,
      );
    } catch (e) {
      final revertedMap = Map<String, bool>.from(_favorites!.doctorIds)
        ..[doctorId] = current;

      _favorites = FavoriteModel(
        patientId: patientId,
        doctorIds: revertedMap,
        pharmacyIds: _favorites!.pharmacyIds,
      );

      if (isClosed) return;

      emit(
        FavoriteLoaded(
          favorites: _favorites!,
          favoriteDoctors: _favoriteDoctors,
        ),
      );

      emit(FavoriteError(e.toString()));
    }
  }

  Future<void> toggleFavoritePharmacy(String patientId, String pharmacyId) async {
    if (_favorites == null) {
      _favorites = FavoriteModel(
        patientId: patientId,
        doctorIds: {},
        pharmacyIds: {},
      );
    }
    // optimistic update — flip immediately in UI
    final current = _favorites!.isFavoritePharmacy(pharmacyId);
    final updatedMap = Map<String, bool>.from(_favorites!.pharmacyIds)
      ..[pharmacyId] = !current;

    _favorites = FavoriteModel(
      patientId: patientId,
      doctorIds: _favorites!.doctorIds,
      pharmacyIds: updatedMap,
    );

    if (isClosed) return;

    emit(
      FavoriteLoaded(
        favorites: _favorites!,
        favoriteDoctors: _favoriteDoctors,
      ),
    );

    try {
      await _repository.toggleFavoritePharmacy(patientId, pharmacyId, !current);
    } catch (e) {
      // revert on failure
      final revertedMap = Map<String, bool>.from(_favorites!.pharmacyIds)
        ..[pharmacyId] = current;
      _favorites = FavoriteModel(
        patientId: patientId,
        doctorIds: _favorites!.doctorIds,
        pharmacyIds: revertedMap,
      );

      if (isClosed) return;

      emit(
        FavoriteLoaded(
          favorites: _favorites!,
          favoriteDoctors: _favoriteDoctors,
        ),
      );
      emit(FavoriteError(e.toString()));
    }
  }

  Future<void> getFavoriteDoctors(String patientId) async {
    if (isClosed) return;

    emit(const FavoriteLoading());

    try {
      _favoriteDoctors = await _repository.getFavoriteDoctors();

      if (isClosed) return;

      emit(
        FavoriteLoaded(
          favorites: _favorites ??
              FavoriteModel(
                patientId: patientId,
                doctorIds: {},
                pharmacyIds: {},
              ),
          favoriteDoctors: _favoriteDoctors,
        ),
      );
    } catch (e) {
      if (isClosed) return;

      emit(FavoriteError(e.toString()));
    }
  }

  bool isFavorite(String doctorId) =>
      _favorites?.isFavoriteDoctor(doctorId) ?? false;

  bool isFavoritePharmacy(String pharmacyId) =>
      _favorites?.isFavoritePharmacy(pharmacyId) ?? false;

  List<DoctorModel> get favoriteDoctors => _favoriteDoctors;
}