import 'package:avo_app/app/core/constants/database_paths.dart';
import 'package:avo_app/app/core/models/pharmacy_model.dart';
import 'package:avo_app/app/core/models/pharmacy_order_model.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer.dart';
import 'package:avo_app/app/core/services/remote/firebase_query_params.dart';

class PharmacyRepositoryImpl {
  final FirebaseConsumer _consumer;

  PharmacyRepositoryImpl({required FirebaseConsumer consumer})
      : _consumer = consumer;

  Future<PharmacyModel?> getPharmacyProfile(String pharmacyId) async {
    try {
      return await _consumer.get(
        '${DatabasePaths.pharmacies}/$pharmacyId',
        fromJson: (json) => PharmacyModel.fromJson(json),
      );
    } catch (e) {
      return null;
    }
  }

  Future<List<PharmacyOrderModel>> getPharmacyOrders(String pharmacyId) async {
    try {
      return await _consumer.getList(
        DatabasePaths.pharmacyOrders,
        fromJson: (json) => PharmacyOrderModel.fromJson(json),
        queryParams: FirebaseQueryParams(
          orderByChild: 'pharmacyId',
          equalTo: pharmacyId,
        ),
      );
    } catch (e) {
      return [];
    }
  }

  Stream<List<PharmacyOrderModel>> streamPharmacyOrders(String pharmacyId) {
    return _consumer.streamList(
      DatabasePaths.pharmacyOrders,
      fromJson: (json) => PharmacyOrderModel.fromJson(json),
      queryParams: FirebaseQueryParams(
        orderByChild: 'pharmacyId',
        equalTo: pharmacyId,
      ),
    );
  }

  Stream<List<PharmacyOrderModel>> streamPatientPharmacyOrders(String patientId) {
    return _consumer.streamList(
      DatabasePaths.pharmacyOrders,
      fromJson: (json) => PharmacyOrderModel.fromJson(json),
      queryParams: FirebaseQueryParams(
        orderByChild: 'patientId',
        equalTo: patientId,
      ),
    );
  }

  Future<void> updateOrderStatus(String orderId, String status, {String? note, required String patientId}) async {
    final updateData = <String, dynamic>{
      'status': status,
    };
    if (note != null && note.isNotEmpty) {
      updateData['note'] = note;
    }

    await _consumer.update(
      '${DatabasePaths.pharmacyOrders}/$orderId',
      data: updateData,
    );

    // Send a notification to the patient
    final notificationData = {
      'title': 'Pharmacy Order Update',
      'body': 'Your order is now $status.',
      'type': 'pharmacy_order',
      'isRead': false,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _consumer.push('${DatabasePaths.notifications}/$patientId', data: notificationData);
  }

  Future<int> getPharmacyOrdersCount(String pharmacyId) async {
    final orders = await getPharmacyOrders(pharmacyId);
    return orders.length;
  }
}
