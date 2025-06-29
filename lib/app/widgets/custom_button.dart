import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? fontSize;
  final FontWeight? fontWeight;
  final IconData? icon;
  final bool outlined;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.fontSize,
    this.fontWeight,
    this.icon,
    this.outlined = false,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;
    
    return SizedBox(
      width: width,
      height: height ?? 48.h,
      child: outlined
          ? OutlinedButton(
              onPressed: isDisabled ? null : onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isDisabled
                      ? AppColors.border
                      : backgroundColor ?? AppColors.primary,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius.r),
                ),
                backgroundColor: Colors.transparent,
              ),
              child: _buildButtonContent(
                textColor: isDisabled
                    ? AppColors.textHint
                    : backgroundColor ?? AppColors.primary,
              ),
            )
          : ElevatedButton(
              onPressed: isDisabled ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDisabled
                    ? AppColors.border
                    : backgroundColor ?? AppColors.primary,
                foregroundColor: textColor ?? AppColors.textWhite,
                elevation: isDisabled ? 0 : 2,
                shadowColor: AppColors.shadow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius.r),
                ),
              ),
              child: _buildButtonContent(
                textColor: isDisabled
                    ? AppColors.textHint
                    : textColor ?? AppColors.textWhite,
              ),
            ),
    );
  }

  Widget _buildButtonContent({required Color textColor}) {
    if (isLoading) {
      return SpinKitThreeBounce(
        color: textColor,
        size: 20.sp,
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20.sp,
            color: textColor,
          ),
          SizedBox(width: 8.w),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize ?? 16.sp,
              fontWeight: fontWeight ?? FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize ?? 16.sp,
        fontWeight: fontWeight ?? FontWeight.w600,
        color: textColor,
      ),
    );
  }
}
