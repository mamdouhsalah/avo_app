import 'package:avo_app/app/core/models/favorite_model.dart';

abstract class FavoriteState {
  const FavoriteState();
}

class FavoriteInitial extends FavoriteState {
  const FavoriteInitial();
}

class FavoriteLoading extends FavoriteState {
  const FavoriteLoading();
}

class FavoriteLoaded extends FavoriteState {
  final FavoriteModel favorites;
  const FavoriteLoaded(this.favorites);
}

class FavoriteError extends FavoriteState {
  final String message;
  const FavoriteError(this.message);
}