import 'package:avo_app/app/features/auth/data/auth_repository.dart';
import 'package:avo_app/app/features/splash/logic/splash_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashCubit extends Cubit<SplashState> {
  final AuthRepository repository;
  SplashCubit({required this.repository}) : super(SplashInitial());

  Future<void> checkToken() async {
    emit(SplashLoading());
    try {
      final user = await repository.checkToken();
      if (user != null) {
        if (user.isVerified == true) {
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
