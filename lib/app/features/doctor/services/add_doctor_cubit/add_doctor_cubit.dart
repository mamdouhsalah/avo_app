import 'package:avo_app/app/core/models/schedule_model.dart';
import 'package:avo_app/app/core/utils/date_calculator.dart';
import 'package:avo_app/app/features/doctor/data/doctor_repository.dart';
import 'package:avo_app/app/features/doctor/services/add_doctor_cubit/add_doctor_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddDoctorCubit extends Cubit<AddDoctorState> {
  final DoctorRepository repository;
  List<ScheduleModel> _localSchedules = [];

  List<ScheduleModel> get localSchedules => _localSchedules;

  // Form inputs state
  String selectedDay = 'Monday';
  String startTime = '';
  String endTime = '';
  final TextEditingController maxVisitsController = TextEditingController();
  int? editingIndex;

  AddDoctorCubit({required this.repository}) : super(AddDoctorInitial());

  void initForm({ScheduleModel? schedule, int? index}) {
    if (schedule != null) {
      selectedDay = schedule.day;
      startTime = schedule.startTime;
      endTime = schedule.endTime;
      maxVisitsController.text = schedule.maxVisits.toString();
      editingIndex = index;
    } else {
      selectedDay = 'Monday';
      startTime = '';
      endTime = '';
      maxVisitsController.text = '10';
      editingIndex = null;
    }
  }

  void setDay(String day) {
    selectedDay = day;
  }

  void setStartTime(String time) {
    startTime = time;
  }

  void setEndTime(String time) {
    endTime = time;
  }

  Future<void> saveScheduleSlot() async {
    final visits = int.tryParse(maxVisitsController.text.trim()) ?? 10;
    emit(AddDoctorScheduleLoading());
    try {
      if (editingIndex != null) {
        final oldSchedule = _localSchedules[editingIndex!];
        final schedule = ScheduleModel(
          id: oldSchedule.id,
          day: selectedDay,
          date: formatCalculationDate(calculateNextDateForWeekday(selectedDay)),
          startTime: startTime,
          endTime: endTime,
          maxVisits: visits,
          currentVisits: oldSchedule.currentVisits,
        );
        await repository.updateDoctorSchedule(schedule);
        _localSchedules[editingIndex!] = schedule;
        emit(AddDoctorScheduleActionSuccess("Schedule updated successfully"));
      } else {
        final schedule = ScheduleModel(
          id: '',
          day: selectedDay,
          date: formatCalculationDate(calculateNextDateForWeekday(selectedDay)),
          startTime: startTime,
          endTime: endTime,
          maxVisits: visits,
          currentVisits: 0,
        );
        final newId = await repository.addDoctorSchedule(schedule);
        final savedSchedule = ScheduleModel(
          id: newId,
          day: schedule.day,
          date: schedule.date,
          startTime: schedule.startTime,
          endTime: schedule.endTime,
          maxVisits: schedule.maxVisits,
          currentVisits: schedule.currentVisits,
        );
        _localSchedules.add(savedSchedule);
        emit(AddDoctorScheduleActionSuccess("Schedule added successfully"));
      }
      emit(AddDoctorScheduleLoaded(List.from(_localSchedules)));
    } catch (e) {
      emit(AddDoctorScheduleError(e.toString()));
      emit(AddDoctorScheduleLoaded(List.from(_localSchedules)));
    }
  }

  Future<void> loadSchedules() async {
    emit(AddDoctorScheduleLoading());
    try {
      final schedules = await repository.getDoctorSchedules();
      _localSchedules = List.from(schedules);
      emit(AddDoctorScheduleLoaded(_localSchedules));
    } catch (e) {
      emit(AddDoctorScheduleError(e.toString()));
    }
  }

  Future<void> deleteScheduleLocal(int index) async {
    if (index >= 0 && index < _localSchedules.length) {
      final scheduleId = _localSchedules[index].id;
      emit(AddDoctorScheduleLoading());
      try {
        await repository.deleteDoctorSchedule(scheduleId);
        _localSchedules.removeAt(index);
        emit(AddDoctorScheduleActionSuccess("Schedule deleted successfully"));
        emit(AddDoctorScheduleLoaded(List.from(_localSchedules)));
      } catch (e) {
        emit(AddDoctorScheduleError(e.toString()));
        emit(AddDoctorScheduleLoaded(List.from(_localSchedules)));
      }
    }
  }

  @override
  Future<void> close() {
    maxVisitsController.dispose();
    return super.close();
  }
}