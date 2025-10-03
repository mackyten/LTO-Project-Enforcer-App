import 'package:enforcer_auto_fine/pages/violation/bloc/violation_bloc.dart';
import 'package:enforcer_auto_fine/pages/violation/models/violations_config.dart';
import 'package:enforcer_auto_fine/shared/app_theme/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EnhancedViolationItem extends StatefulWidget {
  final String label;
  final String item;
  final int offenseNumber;

  const EnhancedViolationItem({
    super.key, 
    required this.label, 
    required this.item,
    required this.offenseNumber,
  });

  @override
  State<EnhancedViolationItem> createState() => _EnhancedViolationItemState();
}

class _EnhancedViolationItemState extends State<EnhancedViolationItem> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _excessPassengersController = TextEditingController();
  String? selectedOption;

  @override
  void dispose() {
    _priceController.dispose();
    _excessPassengersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ViolationBloc, ViolationState>(
      builder: (context, state) {
        if (state is! HomeLoaded) {
          return const SizedBox.shrink();
        }

        final violations = state.violations;
        final violationData = violations[widget.item];
        final isSelected = violationData != false;
        final violationDef = ViolationsConfig.definitions[widget.item];

        if (violationDef == null) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              // Main violation selector
              GestureDetector(
                onTap: () => _toggleViolation(context, violationDef),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF007AFF).withOpacity(0.15)
                        : Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF007AFF)
                          : Colors.white.withOpacity(0.12),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF007AFF)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF007AFF)
                                    : Colors.white.withOpacity(0.5),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.label,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (violationDef.type == ViolationType.fixed && violationDef.prices != null)
                                  Text(
                                    _getFixedPriceText(violationDef),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: FontSizes().caption,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Custom input section for selected violations
              if (isSelected && violationDef.requiresCustomInput())
                _buildCustomInputSection(context, violationDef, violationData),
            ],
          ),
        );
      },
    );
  }

  String _getFixedPriceText(ViolationDefinition violationDef) {
    final price = violationDef.getPriceForOffense(widget.offenseNumber);
    return 'Fine: ₱${price.toStringAsFixed(0)}';
  }

  void _toggleViolation(BuildContext context, ViolationDefinition violationDef) {
    final state = context.read<ViolationBloc>().state;
    if (state is! HomeLoaded) return;

    final currentValue = state.violations[widget.item];
    final isCurrentlySelected = currentValue != false;

    if (isCurrentlySelected) {
      // Deselect
      context.read<ViolationBloc>().add(
        UpdateViolationEvent(key: widget.item, value: false),
      );
    } else {
      // Select with default data
      final defaultData = _getDefaultViolationData(violationDef);
      context.read<ViolationBloc>().add(
        UpdateViolationEvent(key: widget.item, value: defaultData),
      );
    }
    HapticFeedback.lightImpact();
  }

  Map<String, dynamic> _getDefaultViolationData(ViolationDefinition violationDef) {
    switch (violationDef.type) {
      case ViolationType.fixed:
        return {
          'repetition': widget.offenseNumber,
          'price': violationDef.getPriceForOffense(widget.offenseNumber),
        };
      case ViolationType.range:
        if (violationDef.options != null && violationDef.optionPrices != null) {
          return {
            'repetition': widget.offenseNumber,
            'price': violationDef.optionPrices![0],
            'option': violationDef.options![0],
          };
        } else {
          return {
            'repetition': widget.offenseNumber,
            'price': violationDef.minPrice ?? 1000.0,
          };
        }
      case ViolationType.calculated:
        return {
          'repetition': widget.offenseNumber,
          'price': violationDef.getPriceForOffense(widget.offenseNumber),
          'excessPassengers': 0,
        };
    }
  }

  Widget _buildCustomInputSection(BuildContext context, ViolationDefinition violationDef, dynamic violationData) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (violationDef.type == ViolationType.range && violationDef.options != null)
            _buildOptionSelector(context, violationDef, violationData),
          
          if (violationDef.type == ViolationType.range && violationDef.options == null)
            _buildPriceRangeInput(context, violationDef, violationData),
          
          if (violationDef.type == ViolationType.calculated)
            _buildCalculatedInput(context, violationDef, violationData),
        ],
      ),
    );
  }

  Widget _buildOptionSelector(BuildContext context, ViolationDefinition violationDef, dynamic violationData) {
    final currentOption = violationData is Map<String, dynamic> ? violationData['option'] : null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select type:',
          style: TextStyle(
            color: Colors.white,
            fontSize: FontSizes().body,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ...violationDef.options!.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final isSelected = currentOption == option;
          
          return GestureDetector(
            onTap: () => _updateViolationOption(context, violationDef, option, index),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(0xFF007AFF).withOpacity(0.2)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected 
                      ? const Color(0xFF007AFF)
                      : Colors.white.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF007AFF) : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? const Color(0xFF007AFF) : Colors.white.withOpacity(0.5),
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 10)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    option,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: FontSizes().body,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPriceRangeInput(BuildContext context, ViolationDefinition violationDef, dynamic violationData) {
    final currentPrice = violationData is Map<String, dynamic> ? violationData['price'] : violationDef.minPrice;
    
    if (_priceController.text.isEmpty && currentPrice != null) {
      _priceController.text = currentPrice.toStringAsFixed(0);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter fine amount:',
          style: TextStyle(
            color: Colors.white,
            fontSize: FontSizes().body,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _priceController,
          keyboardType: TextInputType.number,
          style: TextStyle(color: Colors.white, fontSize: 17),
          decoration: InputDecoration(
            hintText: 'Amount (₱${violationDef.minPrice?.toStringAsFixed(0)} - ₱${violationDef.maxPrice?.toStringAsFixed(0)})',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Color(0xFF007AFF), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          onChanged: (value) => _updateViolationPrice(context, violationDef, value),
        ),
      ],
    );
  }

  Widget _buildCalculatedInput(BuildContext context, ViolationDefinition violationDef, dynamic violationData) {
    final currentExcess = violationData is Map<String, dynamic> ? violationData['excessPassengers'] : 0;
    
    if (_excessPassengersController.text.isEmpty && currentExcess != null) {
      _excessPassengersController.text = currentExcess.toString();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Number of excess passengers:',
          style: TextStyle(
            color: Colors.white,
            fontSize: FontSizes().body,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _excessPassengersController,
          keyboardType: TextInputType.number,
          style: TextStyle(color: Colors.white, fontSize: 17),
          decoration: InputDecoration(
            hintText: 'Number of excess passengers',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Color(0xFF007AFF), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          onChanged: (value) => _updateExcessPassengers(context, violationDef, value),
        ),
        const SizedBox(height: 8),
        Text(
          'Base fine: ₱${violationDef.getPriceForOffense(widget.offenseNumber).toStringAsFixed(0)} + ₱${violationDef.excessPassengerFee?.toStringAsFixed(0)} per excess passenger',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: FontSizes().caption,
          ),
        ),
      ],
    );
  }

  void _updateViolationOption(BuildContext context, ViolationDefinition violationDef, String option, int index) {
    final state = context.read<ViolationBloc>().state;
    if (state is! HomeLoaded) return;

    final currentData = state.violations[widget.item] as Map<String, dynamic>;
    final newPrice = violationDef.optionPrices![index];
    
    final updatedData = Map<String, dynamic>.from(currentData);
    updatedData['option'] = option;
    updatedData['price'] = newPrice;
    
    context.read<ViolationBloc>().add(
      UpdateViolationEvent(key: widget.item, value: updatedData),
    );
  }

  void _updateViolationPrice(BuildContext context, ViolationDefinition violationDef, String value) {
    final state = context.read<ViolationBloc>().state;
    if (state is! HomeLoaded) return;

    final price = double.tryParse(value) ?? violationDef.minPrice ?? 1000.0;
    final clampedPrice = price.clamp(violationDef.minPrice ?? 0, violationDef.maxPrice ?? double.infinity);
    
    final currentData = state.violations[widget.item] as Map<String, dynamic>;
    final updatedData = Map<String, dynamic>.from(currentData);
    updatedData['price'] = clampedPrice;
    
    context.read<ViolationBloc>().add(
      UpdateViolationEvent(key: widget.item, value: updatedData),
    );
  }

  void _updateExcessPassengers(BuildContext context, ViolationDefinition violationDef, String value) {
    final state = context.read<ViolationBloc>().state;
    if (state is! HomeLoaded) return;

    final excessPassengers = int.tryParse(value) ?? 0;
    final basePrice = violationDef.getPriceForOffense(widget.offenseNumber);
    final totalPrice = basePrice + (excessPassengers * (violationDef.excessPassengerFee ?? 0));
    
    final currentData = state.violations[widget.item] as Map<String, dynamic>;
    final updatedData = Map<String, dynamic>.from(currentData);
    updatedData['excessPassengers'] = excessPassengers;
    updatedData['price'] = totalPrice;
    
    context.read<ViolationBloc>().add(
      UpdateViolationEvent(key: widget.item, value: updatedData),
    );
  }
}
