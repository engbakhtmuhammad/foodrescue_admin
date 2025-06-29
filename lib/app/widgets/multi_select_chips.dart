import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';

class MultiSelectDropdown<T> extends StatefulWidget {
  final String label;
  final String hintText;
  final List<T> items;
  final List<String> selectedIds;
  final String Function(T) getItemId;
  final String Function(T) getItemTitle;
  final void Function(String) onToggle;
  final bool isLoading;

  const MultiSelectDropdown({
    super.key,
    required this.label,
    required this.hintText,
    required this.items,
    required this.selectedIds,
    required this.getItemId,
    required this.getItemTitle,
    required this.onToggle,
    this.isLoading = false,
  });

  @override
  State<MultiSelectDropdown<T>> createState() => _MultiSelectDropdownState<T>();
}

class _MultiSelectDropdownState<T> extends State<MultiSelectDropdown<T>> {
  bool _isExpanded = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void _toggleDropdown() {
    if (_isExpanded) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isExpanded = true;
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isExpanded = false;
      });
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 4,
        width: size.width,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: 200.h,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.border),
            ),
            child: widget.isLoading
                ? Container(
                    height: 100.h,
                    child: const Center(child: CircularProgressIndicator()),
                  )
                : widget.items.isEmpty
                    ? Container(
                        height: 100.h,
                        child: Center(
                          child: Text(
                            'No ${widget.label.toLowerCase()} available',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textHint,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: widget.items.length,
                        itemBuilder: (context, index) {
                          final item = widget.items[index];
                          final itemId = widget.getItemId(item);
                          final isSelected = widget.selectedIds.contains(itemId);

                          return InkWell(
                            onTap: () {
                              widget.onToggle(itemId);
                              // Don't close dropdown, allow multiple selections
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.check_box
                                        : Icons.check_box_outline_blank,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      widget.getItemTitle(item),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
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

          // Dropdown Button
          InkWell(
            onTap: widget.isLoading ? null : _toggleDropdown,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: _isExpanded ? AppColors.primary : AppColors.border,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.selectedIds.isEmpty
                          ? widget.hintText
                          : '${widget.selectedIds.length} selected',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: widget.selectedIds.isEmpty
                            ? AppColors.textHint
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: AppColors.textSecondary,
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ),

          // Selected Items as Chips
          if (widget.selectedIds.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: widget.selectedIds.map((selectedId) {
                final item = widget.items.firstWhere(
                  (item) => widget.getItemId(item) == selectedId,
                  orElse: () => widget.items.first,
                );

                return Chip(
                  label: Text(
                    widget.getItemTitle(item),
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
                  onDeleted: () => widget.onToggle(selectedId),
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
          ],
        ],
      ),
    );
  }
}
