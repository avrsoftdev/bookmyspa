import 'package:flutter/material.dart';

class SpaSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  const SpaSearchField({super.key, required this.controller, this.onChanged, this.focusNode});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search Spa and Services',
        prefixIcon: const Icon(Icons.search_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
