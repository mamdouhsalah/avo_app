import 'package:avo_app/app/features/auth/data/auth_repository.dart';
import 'package:avo_app/app/features/splash/logic/splash_state.dart';
import 'package:avo_app/app/core/services/remote/sync_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashCubit extends Cubit<SplashState> {
  final AuthRepository repository;
  final SyncRepository syncRepository;

  SplashCubit({required this.repository, required this.syncRepository}) : super(SplashInitial());

  Future<void> checkToken() async {
    emit(SplashLoading());
    try {
      final user = await repository.checkToken();
      if (user != null) {
        // تم دمج صلاحية الأدمن من main مع عملية المزامنة من فرعك
        if (user.isVerified == true || user.role == 'admin') {
          // Initial Data Sync: fetch meds from Firebase if local is cleared (e.g. fresh install)
          await syncRepository.syncMedicationsFromRemote();
          await syncRepository.syncAnalysesFromRemote();
          emit(SplashSuccess(user.role));
        } else {
          emit(SplashUnverified(user.role));
        }
      } else {
        emit(SplashFailure('No token found'));
      }
    } catch (e) {
      emit(SplashFailure(e.toString()));
    }
  }
}