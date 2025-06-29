import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';
import '../utils/app_utils.dart';

class RecentDataWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Map<String, String>> items;
  final VoidCallback? onViewAll;

  const RecentDataWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Items List
            if (items.isEmpty)
              Container(
                padding: EdgeInsets.symmetric(vertical: 32.h),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox,
                        color: AppColors.textHint,
                        size: 48.sp,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'No data available',
                        style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: items.take(5).map((item) => _buildListItem(item)).toList(),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildListItem(Map<String, String> item) {
    final status = item['status'] ?? '';
    final statusColor = AppUtils.getStatusColor(status);
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] ?? '',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item['subtitle']?.isNotEmpty == true) ...[
                  SizedBox(height: 4.h),
                  Text(
                    item['subtitle']!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          
          if (status.isNotEmpty) ...[
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 4.h,
              ),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: statusColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                AppUtils.capitalizeFirst(status),
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
