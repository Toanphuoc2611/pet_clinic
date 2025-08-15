import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admin/bloc/analytics/analytics_event.dart';
import 'package:admin/bloc/analytics/analytics_state.dart';
import 'package:admin/repository/invoice/invoice_repository.dart';
import 'package:admin/dto/result_file.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final InvoiceRepository invoiceRepository;

  AnalyticsBloc(this.invoiceRepository) : super(AnalyticsInitial()) {
    on<AnalyticsGetDailyRevenueStarted>(_onGetDailyRevenueStarted);
    on<AnalyticsGetRevenueStatsStarted>(_onGetRevenueStatsStarted);
  }

  void _onGetDailyRevenueStarted(
    AnalyticsGetDailyRevenueStarted event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading());

    try {
      // Tạo dữ liệu mẫu cho biểu đồ (trong thực tế sẽ gọi API)
      final Map<String, int> dailyRevenue = {};
      int totalRevenue = 0;

      // Giả lập dữ liệu doanh thu theo ngày
      final startDate = DateTime.parse(event.startDate);
      final endDate = DateTime.parse(event.endDate);
      final days = endDate.difference(startDate).inDays + 1;

      for (int i = 0; i < days; i++) {
        final date = startDate.add(Duration(days: i));
        final dateStr = date.toIso8601String().split('T')[0];

        // Tạo doanh thu ngẫu nhiên (trong thực tế sẽ lấy từ API)
        final revenue = _generateRandomRevenue(i, days);
        dailyRevenue[dateStr] = revenue;
        totalRevenue += revenue;
      }

      emit(
        AnalyticsDailyRevenueSuccess(
          dailyRevenue: dailyRevenue,
          totalRevenue: totalRevenue,
        ),
      );
    } catch (e) {
      emit(AnalyticsFailure('Lỗi khi tải dữ liệu: $e'));
    }
  }

  void _onGetRevenueStatsStarted(
    AnalyticsGetRevenueStatsStarted event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading());

    try {
      // Lấy doanh thu tổng từ repository
      final result =
          event.doctorId != null
              ? await invoiceRepository.getRevenueByDoctor(
                event.startDate,
                event.endDate,
                event.doctorId!,
              )
              : await invoiceRepository.getRevenue(
                event.startDate,
                event.endDate,
              );

      if (result is Success<int>) {
        final totalRevenue = result.data;
        final startDate = DateTime.parse(event.startDate);
        final endDate = DateTime.parse(event.endDate);
        final totalDays = endDate.difference(startDate).inDays + 1;
        final averageDaily = totalRevenue / totalDays;

        // Giả lập max và min daily (trong thực tế sẽ tính từ dữ liệu thực)
        final maxDaily = (averageDaily * 1.5).round();
        final minDaily = (averageDaily * 0.5).round();

        emit(
          AnalyticsRevenueStatsSuccess(
            totalRevenue: totalRevenue,
            averageDaily: averageDaily,
            totalDays: totalDays,
            maxDaily: maxDaily,
            minDaily: minDaily,
          ),
        );
      } else if (result is Failure<int>) {
        emit(AnalyticsFailure(result.message));
      }
    } catch (e) {
      emit(AnalyticsFailure('Lỗi khi tải thống kê: $e'));
    }
  }

  int _generateRandomRevenue(int dayIndex, int totalDays) {
    // Tạo pattern doanh thu giả lập
    final baseRevenue = 1000000; // 1 triệu VND
    final variation = (dayIndex % 7) * 200000; // Biến động theo ngày trong tuần
    final trend =
        (dayIndex / totalDays) * 500000; // Xu hướng tăng theo thời gian

    return (baseRevenue + variation + trend).round();
  }
}
