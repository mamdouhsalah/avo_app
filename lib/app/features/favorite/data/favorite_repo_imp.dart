import 'package:avo_app/app/core/errors/database_exception.dart';
import 'package:avo_app/app/core/models/favorite_model.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer.dart';
import 'package:avo_app/app/features/favorite/data/favorit_repo.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FirebaseConsumer _consumer;

  FavoriteRepositoryImpl({required FirebaseConsumer consumer})
      : _consumer = consumer;

  @override
  Future<FavoriteModel> getFavorites(String patientId) async {
    try {
      final data = await _consumer.get('favorites/$patientId',
          fromJson: (json) => FavoriteModel.fromJson(patientId, json));
      return data;
    } catch (e) {
      throw DatabaseException(e.toString(), "failed to set favorite");
    }
  }

  @override
  Future<void> toggleFavorite(
    String patientId,
    String doctorId,
    bool isFavorite,
  ) async {
    try {
      await _consumer.update(
        'favorites/$patientId/doctors',
        data: {doctorId: isFavorite},
      );
    } catch (e) {
      throw DatabaseException(e.toString(), "failed to toggle");
    }
  }

  @override
  Future<void> toggleFavoritePharmacy(
    String patientId,
    String pharmacyId,
    bool isFavorite,
  ) async {
    try {
      await _consumer.update(
        'favorites/$patientId/pharmacies',
        data: {pharmacyId: isFavorite},
      );
    } catch (e) {
      throw DatabaseException(e.toString(), "failed to toggle pharmacy");
    }
  }
}
