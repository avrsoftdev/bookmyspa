import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/tokens.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const SectionCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            SizedBox(height: 12.h),
            child,
          ],
        ),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int? maxLines;
  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: AppRadius.md),
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          ),
        ),
      ],
    );
  }
}

class AppDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;
  const AppDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        SizedBox(height: 6.h),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: AppRadius.md),
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          ),
        ),
      ],
    );
  }
}

class TimePickerField extends StatelessWidget {
  final String label;
  final TimeOfDay? value;
  final void Function(TimeOfDay) onChanged;
  const TimePickerField({super.key, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        SizedBox(height: 6.h),
        InkWell(
          onTap: () async {
            final now = TimeOfDay.now();
            final picked = await showTimePicker(context: context, initialTime: value ?? now);
            if (picked != null) onChanged(picked);
          },
          child: InputDecorator(
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: AppRadius.md),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            ),
            child: Text(value != null ? value!.format(context) : 'Select time'),
          ),
        ),
      ],
    );
  }
}

class MultiSelectChips extends StatelessWidget {
  final String label;
  final List<String> options;
  final Set<String> selected;
  final void Function(String, bool) onChanged;
  const MultiSelectChips({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        SizedBox(height: 6.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: options.map((o) {
            final isSelected = selected.contains(o);
            return FilterChip(
              label: Text(o),
              selected: isSelected,
              onSelected: (val) => onChanged(o, val),
              selectedColor: AppColors.primary.withOpacity(0.15),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class CheckboxGroup extends StatelessWidget {
  final String label;
  final List<String> options;
  final Set<String> selected;
  final void Function(String, bool) onChanged;
  const CheckboxGroup({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        SizedBox(height: 6.h),
        Column(
          children: options.map((o) {
            final checked = selected.contains(o);
            return CheckboxListTile(
              value: checked,
              onChanged: (val) => onChanged(o, val ?? false),
              title: Text(o),
              dense: true,
              contentPadding: EdgeInsets.zero,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class FileUploadTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final String? fileName;
  const FileUploadTile({super.key, required this.label, required this.onTap, this.fileName});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.upload_file_rounded),
      title: Text(label),
      subtitle: Text(fileName ?? 'No file selected'),
      trailing: ElevatedButton(
        onPressed: onTap,
        child: const Text('Upload'),
      ),
    );
  }
}

class PhotosUploadGrid extends StatelessWidget {
  final List<ImageProvider?> photos;
  final VoidCallback onAdd;
  final void Function(int) onRemove;
  final int maxPhotos;
  const PhotosUploadGrid({
    super.key,
    required this.photos,
    required this.onAdd,
    required this.onRemove,
    this.maxPhotos = 10,
  });

  @override
  Widget build(BuildContext context) {
    final canAdd = photos.length < maxPhotos;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8.w,
        crossAxisSpacing: 8.w,
        childAspectRatio: 1,
      ),
      itemCount: photos.length + (canAdd ? 1 : 0),
      itemBuilder: (context, index) {
        if (canAdd && index == photos.length) {
          return InkWell(
            onTap: onAdd,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: AppRadius.md,
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                color: AppColors.primary.withOpacity(0.05),
              ),
              child: const Center(child: Icon(Icons.add_a_photo_rounded)),
            ),
          );
        }
        final photo = photos[index];
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: AppRadius.md,
                color: Colors.grey[200],
                image: photo != null
                    ? DecorationImage(image: photo, fit: BoxFit.cover)
                    : null,
              ),
            ),
            Positioned(
              right: 6,
              top: 6,
              child: InkWell(
                onTap: () => onRemove(index),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}

