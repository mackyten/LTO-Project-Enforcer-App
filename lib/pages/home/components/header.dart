import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
final VoidCallback previousStep;
  final Animation<double> progressAnimation;

  const Header({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.previousStep,
    required this.progressAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: currentStep > 0 ? previousStep : null,
                child: AnimatedOpacity(
                  opacity: currentStep > 0 ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 300),
                  child: Text(
                    '← Back',
                    style: TextStyle(
                      color: Color(0xFF007AFF),
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${currentStep + 1} of $totalSteps',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Text(
            'Violation Report',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Help keep our community safe',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 17,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 20),
          AnimatedBuilder(
            animation: progressAnimation,
            builder: (context, child) {
              return Container(
                width: double.infinity,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF007AFF),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
