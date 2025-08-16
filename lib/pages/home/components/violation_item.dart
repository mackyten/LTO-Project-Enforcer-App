// violation_item.dart
import 'package:enforcer_auto_fine/pages/home/bloc/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViolationItem extends StatelessWidget {
  final String label;
  final String item;

  const ViolationItem({super.key, required this.label, required this.item});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is! HomeLoaded) {
          return const SizedBox.shrink();
        } else {
          final violations = state.violations;
          bool? value = violations[item] ?? false;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () {
                context.read<HomeBloc>().add(
                  UpdateViolationEvent(
                    key: item,
                    value: !value, // Toggle the value
                  ),
                );
                HapticFeedback.lightImpact();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: value
                      ? const Color(0xFF007AFF).withOpacity(0.15)
                      : Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: value
                        ? const Color(0xFF007AFF)
                        : Colors.white.withOpacity(0.12),
                    width: value ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: value
                            ? const Color(0xFF007AFF)
                            : Colors.transparent,
                        border: Border.all(
                          color: value
                              ? const Color(0xFF007AFF)
                              : Colors.white.withOpacity(0.5),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: value
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
