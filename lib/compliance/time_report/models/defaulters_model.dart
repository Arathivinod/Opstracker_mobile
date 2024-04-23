import 'dart:convert';

class Defaulter {
  final String name;
  final String empId;
  final List<DateTime> missedDates;

  Defaulter({
    required this.name,
    required this.empId,
    required this.missedDates,
  });
  factory Defaulter.fromJson(Map<String, dynamic> json) {
    return Defaulter(
      name: json['name'] ?? '',
      empId: json['empId'] ?? '',
      // You may need to modify this part based on your JSON structure
      missedDates: (json['missedDates'] as List<dynamic>?)
              ?.map((date) => DateTime.parse(date))
              .toList() ??
          [],
    );
  }
}

class TimeReportData {
  final List<Defaulter> defaulters;

  TimeReportData({
    required this.defaulters,
  });

  factory TimeReportData.fromJson(Map<String, dynamic> json) {
    final List<dynamic> responseData = json['responseData'];
    List<Defaulter> defaulters = responseData
        .map<Defaulter>((defaulterData) => Defaulter.fromJson(defaulterData))
        .toList();

    return TimeReportData(
      defaulters: defaulters,
    );
  }
  int get totalDefaulters => defaulters.length;

  Map<DateTime, int> getTotalDefaultersPerDay() {
    Map<DateTime, int> defaultersPerDay = {};

    for (Defaulter defaulter in defaulters) {
      for (DateTime date in defaulter.missedDates) {
        defaultersPerDay.update(date, (value) => value + 1, ifAbsent: () => 1);
      }
    }

    return defaultersPerDay;
  }

  Map<DateTime, int> getTotalDefaultersPerWeek() {
    Map<DateTime, int> defaultersPerWeek = {};

    for (Defaulter defaulter in defaulters) {
      for (DateTime date in defaulter.missedDates) {
        DateTime startOfWeek = DateTime.utc(date.year, date.month, date.day);
        startOfWeek =
            startOfWeek.subtract(Duration(days: startOfWeek.weekday - 1));

        defaultersPerWeek.update(startOfWeek, (value) => value + 1,
            ifAbsent: () => 1);
      }
    }

    return defaultersPerWeek;
  }
}

TimeReportData parseApiResponse(String jsonResponse) {
  final Map<String, dynamic> parsedResponse = json.decode(jsonResponse);
  return TimeReportData.fromJson(parsedResponse);
}
