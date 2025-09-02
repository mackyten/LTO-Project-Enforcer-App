import 'package:enforcer_auto_fine/pages/home/components/title.dart';
import 'package:enforcer_auto_fine/pages/home/models.dart';
import 'package:enforcer_auto_fine/pages/violation/models/report_model.dart';
import 'package:enforcer_auto_fine/shared/app_theme/colors.dart';
import 'package:enforcer_auto_fine/shared/app_theme/fonts.dart';
import 'package:flutter/material.dart';

class WeeklySummary extends StatelessWidget {
  final WeekleySummaryModel weekleySummary;
  const WeeklySummary({super.key, required this.weekleySummary});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleBuilder(
                title: 'Weekly Summary',
                icon: Icon(Icons.assessment, color: MainColor().success),
              ),
              SizedBox(height: 16),

              Row(
                children: [
                  _buildSummaryCard(
                    'Total Violations',
                    weekleySummary.totalViolations.toString(),
                    MainColor().tertiary,
                  ),
                  SizedBox(width: 16),
                  _buildSummaryCard(
                    'This Week',
                    weekleySummary.thisWeeksViolation.toString(),
                    MainColor().tertiary,
                  ),
                ],
              ),
              SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: MainColor().background,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Most Common Violations",
                      style: TextStyle(
                        fontSize: FontSizes().h4,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Divider(),

                    Column(
                      children: weekleySummary.mostCommon.asMap().entries.map((
                        entry,
                      ) {
                        return _buildViolationItem(entry.key, entry.value);
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViolationItem(int index, CommonViolationModel item) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Row(
            children: [
              Text(
                "${index + 1}. ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(item.violationName),
            ],
          ),
          CircleAvatar(
            radius: 10,
            backgroundColor: MainColor().tertiary,
            child: Text(
              item.count.toString(),
              style: TextStyle(
                color: MainColor().textPrimary,
                fontSize: FontSizes().caption,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String count, Color color) {
    return Expanded(
      child: Container(
        constraints: BoxConstraints(maxWidth: 300),
        height: 100,
        child: Card(
          color: color,
          elevation: 10,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                count,
                style: TextStyle(
                  color: MainColor().textPrimary,
                  fontSize: FontSizes().h2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  color: MainColor().textPrimary,
                  fontSize: FontSizes().caption,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
