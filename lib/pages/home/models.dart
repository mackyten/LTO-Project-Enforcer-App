import 'package:enforcer_auto_fine/pages/violation/models/report_model.dart';

class WeekleySummaryModel {
  final int totalViolations;
  final int thisWeeksViolation;
  final List<CommonViolationModel> mostCommon;

  WeekleySummaryModel({
    required this.totalViolations,
    required this.thisWeeksViolation,
    required this.mostCommon,
  });

  factory WeekleySummaryModel.fromJson(Map<String, dynamic> json) {
    var list = json['mostCommon'] as List;
    List<CommonViolationModel> mostCommonList = list
        .map((i) => CommonViolationModel.fromJson(i))
        .toList();

    return WeekleySummaryModel(
      totalViolations: json['totalViolations'] as int? ?? 0,
      thisWeeksViolation: json['thisWeeksViolation'] as int? ?? 0,
      mostCommon: mostCommonList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalViolations': totalViolations,
      'thisWeeksViolation': thisWeeksViolation,
      'mostCommon': mostCommon.map((v) => v.toJson()).toList(),
    };
  }
}

class CommonViolationModel {
  final String violationName;
  final int count;

  CommonViolationModel({required this.violationName, required this.count});

  // Factory constructor to create an object from JSON
  factory CommonViolationModel.fromJson(Map<String, dynamic> json) {
    return CommonViolationModel(
      violationName: json['violationName'] as String,
      count: json['count'] as int,
    );
  }

  // Method to convert object to JSON
  Map<String, dynamic> toJson() {
    return {'violationName': violationName, 'count': count};
  }
}
