import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';

class ChipTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool enabled;
  final String separator;

  const ChipTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.validator,
    this.enabled = true,
    this.separator = ',',
  });

  @override
  State<ChipTextField> createState() => _ChipTextFieldState();
}

class _ChipTextFieldState extends State<ChipTextField> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _chips = [];

  @override
  void initState() {
    super.initState();
    _initializeChips();
    _inputController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _inputController.removeListener(_onTextChanged);
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _initializeChips() {
    if (widget.controller.text.isNotEmpty) {
      _chips = widget.controller.text
          .split(widget.separator)
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
  }

  void _onTextChanged() {
    final text = _inputController.text;
    if (text.contains(widget.separator)) {
      final parts = text.split(widget.separator);
      final newChip = parts[0].trim();
      
      if (newChip.isNotEmpty && !_chips.contains(newChip)) {
        setState(() {
          _chips.add(newChip);
          _updateController();
        });
      }
      
      // Clear the input and set remaining text
      final remainingText = parts.length > 1 ? parts.sublist(1).join(widget.separator) : '';
      _inputController.text = remainingText;
      _inputController.selection = TextSelection.fromPosition(
        TextPosition(offset: remainingText.length),
      );
    }
  }

  void _updateController() {
    widget.controller.text = _chips.join('${widget.separator} ');
  }

  void _removeChip(int index) {
    setState(() {
      _chips.removeAt(index);
      _updateController();
    });
  }

  void _addCurrentText() {
    final text = _inputController.text.trim();
    if (text.isNotEmpty && !_chips.contains(text)) {
      setState(() {
        _chips.add(text);
        _inputController.clear();
        _updateController();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: widget.enabled ? AppColors.surface : AppColors.background,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chips Display
              if (_chips.isNotEmpty) ...[
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: _chips.asMap().entries.map((entry) {
                    final index = entry.key;
                    final chip = entry.value;
                    
                    return Chip(
                      label: Text(
                        chip,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      deleteIcon: Icon(
                        Icons.close,
                        size: 16.sp,
                        color: AppColors.textSecondary,
                      ),
                      onDeleted: widget.enabled ? () => _removeChip(index) : null,
                      backgroundColor: AppColors.background,
                      side: BorderSide(
                        color: AppColors.border,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 8.h),
              ],
              
              // Text Input
              TextFormField(
                controller: _inputController,
                focusNode: _focusNode,
                enabled: widget.enabled,
                validator: widget.validator,
                onFieldSubmitted: (_) => _addCurrentText(),
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText ?? 'Type and press ${widget.separator} to add',
                  hintStyle: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textHint,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  suffixIcon: _inputController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.add,
                            color: AppColors.primary,
                            size: 20.sp,
                          ),
                          onPressed: _addCurrentText,
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
        
        if (_chips.isNotEmpty) ...[
          SizedBox(height: 4.h),
          Text(
            '${_chips.length} item${_chips.length == 1 ? '' : 's'} added',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
