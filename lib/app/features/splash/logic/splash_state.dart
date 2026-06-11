
abstract class SplashState {}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {}

class SplashFailure extends SplashState{
  final String message;
  SplashFailure(this.message);
}
class SplashSuccess extends SplashState{
  final String role;
  SplashSuccess(this.role);
}

