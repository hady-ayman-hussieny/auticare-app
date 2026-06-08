import 'package:auticare/data/models/booking.dart';
import 'package:auticare/data/services/api_client.dart';

class BookingsService {
  Future<BookingModel> createBooking(Map<String, dynamic> data) async {
    final res = await api.post<Map<String, dynamic>>('/bookings', data: data);
    return BookingModel.fromJson(res.data!);
  }

  Future<List<BookingModel>> getMyBookings() async {
    try {
      final res = await api.get<dynamic>('/bookings/my-bookings');
      final list = res.data is List ? res.data as List : [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(BookingModel.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<BookingModel>> getUpcomingBookings() async {
    try {
      final res = await api.get<dynamic>('/bookings/upcoming');
      final list = res.data is List ? res.data as List : [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(BookingModel.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<BookingModel> updateBookingStatus(String id, String status) async {
    final res = await api.patch<Map<String, dynamic>>(
      '/bookings/$id/status',
      data: {'status': status},
    );
    return BookingModel.fromJson(res.data!);
  }

  Future<BookingModel> cancelBooking(String id, {String? reason}) async {
    final res = await api.patch<Map<String, dynamic>>(
      '/bookings/$id/cancel',
      data: {'reason': reason},
    );
    return BookingModel.fromJson(res.data!);
  }

  Future<BookingModel> approveBooking(String id) =>
      updateBookingStatus(id, 'approved');

  Future<BookingModel> completeBooking(String id) =>
      updateBookingStatus(id, 'completed');
}

final bookingsService = BookingsService();
