abstract class AnalyticsEvent {}

class AnalyticsGetDailyRevenueStarted extends AnalyticsEvent {
  final String startDate;
  final String endDate;
  final String? doctorId;

  AnalyticsGetDailyRevenueStarted({
    required this.startDate,
    required this.endDate,
    this.doctorId,
  });
}

class AnalyticsGetRevenueStatsStarted extends AnalyticsEvent {
  final String startDate;
  final String endDate;
  final String? doctorId;

  AnalyticsGetRevenueStatsStarted({
    required this.startDate,
    required this.endDate,
    this.doctorId,
  });
}
