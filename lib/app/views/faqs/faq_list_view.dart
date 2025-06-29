import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/faq_controller.dart';
import '../../constants/app_colors.dart';
import '../../widgets/sidebar_layout.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';
import '../../models/faq_model.dart';

class FaqListView extends StatelessWidget {
  const FaqListView({super.key});

  @override
  Widget build(BuildContext context) {
    final FaqController controller = Get.put(FaqController());
    
    return SidebarLayout(
      title: 'FAQs Management',
      child: Column(
        children: [
          // Header with search and filters
          Container(
            padding: EdgeInsets.all(24.w),
            color: AppColors.surface,
            child: Row(
              children: [
                // Search Field
                Expanded(
                  flex: 3,
                  child: CustomTextField(
                    controller: controller.searchController,
                    label: '',
                    hintText: 'Search FAQs...',
                    prefixIcon: Icons.search,
                  ),
                ),
                
                SizedBox(width: 16.w),
                
                // Category Filter
                Expanded(
                  child: Obx(() => CustomDropdown<String>(
                    label: '',
                    value: controller.selectedCategoryFilter.value,
                    hintText: 'All Categories',
                    items: [
                      const DropdownMenuItem(value: 'all', child: Text('All Categories')),
                      ...FaqModel.categories.map((category) => 
                        DropdownMenuItem(
                          value: category, 
                          child: Text(FaqModel.getCategoryDisplayName(category)),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        controller.setCategoryFilter(value);
                      }
                    },
                  )),
                ),
                
                SizedBox(width: 16.w),
                
                // Status Filter
                Expanded(
                  child: Obx(() => CustomDropdown<String>(
                    label: '',
                    value: controller.selectedStatusFilter.value,
                    hintText: 'All Status',
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Status')),
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        controller.setStatusFilter(value);
                      }
                    },
                  )),
                ),
                
                SizedBox(width: 16.w),
                
                // Add Button
                CustomButton(
                  text: 'Add FAQ',
                  onPressed: () => _showFaqDialog(context, controller),
                  icon: Icons.add,
                ),
              ],
            ),
          ),
          
          // FAQs List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.faqs.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (controller.filteredFaqs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.help_outline,
                        size: 64.sp,
                        color: AppColors.textHint,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No FAQs found',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Create your first FAQ to get started',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return RefreshIndicator(
                onRefresh: () => controller.loadFaqs(refresh: true),
                child: ListView.builder(
                  padding: EdgeInsets.all(24.w),
                  itemCount: controller.filteredFaqs.length,
                  itemBuilder: (context, index) {
                    final faq = controller.filteredFaqs[index];
                    return _buildFaqCard(faq, controller, context);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFaqCard(FaqModel faq, FaqController controller, BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: faq.isActive ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            faq.isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: faq.isActive ? AppColors.success : AppColors.error,
            ),
          ),
        ),
        title: Text(
          faq.question,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.h),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    FaqModel.getCategoryDisplayName(faq.category),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Order: ${faq.order}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                controller.loadFaqForEdit(faq);
                _showFaqDialog(context, controller);
              },
              icon: Icon(
                Icons.edit,
                color: AppColors.primary,
                size: 20.sp,
              ),
              tooltip: 'Edit FAQ',
            ),
            IconButton(
              onPressed: () => controller.toggleFaqStatus(faq),
              icon: Icon(
                faq.isActive ? Icons.visibility_off : Icons.visibility,
                color: faq.isActive ? AppColors.warning : AppColors.success,
                size: 20.sp,
              ),
              tooltip: faq.isActive ? 'Deactivate' : 'Activate',
            ),
            IconButton(
              onPressed: () => _showDeleteDialog(context, controller, faq),
              icon: Icon(
                Icons.delete,
                color: AppColors.error,
                size: 20.sp,
              ),
              tooltip: 'Delete FAQ',
            ),
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Answer:',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  faq.answer,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFaqDialog(BuildContext context, FaqController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Container(
            width: 600.w,
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: controller.formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.currentFaq.value != null ? 'Edit FAQ' : 'Add New FAQ',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Category and Order Row
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() => CustomDropdown<String>(
                          label: 'Category',
                          value: controller.selectedCategory.value,
                          items: FaqModel.categories.map((category) =>
                            DropdownMenuItem(
                              value: category,
                              child: Text(FaqModel.getCategoryDisplayName(category)),
                            ),
                          ).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              controller.selectedCategory.value = value;
                            }
                          },
                        )),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: CustomTextField(
                          controller: controller.orderController,
                          label: 'Display Order',
                          hintText: 'Enter display order (optional)',
                          keyboardType: TextInputType.number,
                          validator: (value) => controller.validateNumber(value, 'Order'),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Question
                  CustomTextField(
                    controller: controller.questionController,
                    label: 'Question',
                    hintText: 'Enter the FAQ question',
                    validator: (value) => controller.validateRequired(value, 'Question'),
                  ),

                  SizedBox(height: 16.h),

                  // Answer
                  CustomTextField(
                    controller: controller.answerController,
                    label: 'Answer',
                    hintText: 'Enter the FAQ answer',
                    maxLines: 4,
                    validator: (value) => controller.validateRequired(value, 'Answer'),
                  ),

                  SizedBox(height: 16.h),

                  // Active Switch
                  Obx(() => SwitchListTile(
                    title: Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    value: controller.selectedIsActive.value,
                    onChanged: (value) {
                      controller.selectedIsActive.value = value;
                    },
                    contentPadding: EdgeInsets.zero,
                  )),

                  SizedBox(height: 24.h),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          controller.clearForm();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Obx(() => CustomButton(
                        text: controller.currentFaq.value != null ? 'Update FAQ' : 'Create FAQ',
                        onPressed: controller.isLoading.value ? null : () async {
                          await controller.saveFaq();
                          if (!controller.isLoading.value) {
                            Navigator.of(context).pop();
                          }
                        },
                        isLoading: controller.isLoading.value,
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, FaqController controller, FaqModel faq) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete FAQ'),
          content: Text('Are you sure you want to delete this FAQ?\n\n"${faq.question}"'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                controller.deleteFaq(faq);
                Navigator.of(context).pop();
              },
              child: Text(
                'Delete',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }
}
