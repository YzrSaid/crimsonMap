import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';

class SearchBarWidget extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const SearchBarWidget({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: const InputDecoration(
        hintText: AppStrings.searchHint,
        prefixIcon: Icon(Icons.search),
        isDense: true,
      ),
    );
  }
}
