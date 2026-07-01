abstract class DoctorRatingState {
  const DoctorRatingState();
}

class DoctorRatingInitial extends DoctorRatingState {
  const DoctorRatingInitial();
}

class DoctorRatingLoading extends DoctorRatingState {
  const DoctorRatingLoading();
}

class DoctorRatingSuccess extends DoctorRatingState {
  final double newDoctorRate;

  const DoctorRatingSuccess(this.newDoctorRate);
}

class DoctorRatingError extends DoctorRatingState {
  final String message;
  const DoctorRatingError(this.message);
}