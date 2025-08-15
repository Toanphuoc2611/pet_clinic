abstract class AnalyticsState {}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class AnalyticsDailyRevenueSuccess extends AnalyticsState {
  final Map<String, int> dailyRevenue;
  final int totalRevenue;

  AnalyticsDailyRevenueSuccess({
    required this.dailyRevenue,
    required this.totalRevenue,
  });
}

class AnalyticsRevenueStatsSuccess extends AnalyticsState {
  final int totalRevenue;
  final double averageDaily;
  final int totalDays;
  final int maxDaily;
  final int minDaily;

  AnalyticsRevenueStatsSuccess({
    required this.totalRevenue,
    required this.averageDaily,
    required this.totalDays,
    required this.maxDaily,
    required this.minDaily,
  });
}

class AnalyticsFailure extends AnalyticsState {
  final String message;

  AnalyticsFailure(this.message);
}
