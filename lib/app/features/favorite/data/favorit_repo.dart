import 'package:avo_app/app/core/models/doctor_model.dart';
import 'package:avo_app/app/core/models/favorite_model.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer.dart';

abstract class FavoriteRepository {
  Future<FavoriteModel> getFavorites(String patientId);
  Future<void> toggleFavorite(String patientId, String doctorId, bool isFavorite);
  Future<List<DoctorModel>> getFavoriteDoctors();
}