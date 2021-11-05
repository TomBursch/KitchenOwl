import 'package:flutter/material.dart';
import 'package:kitchenowl/kitchenowl.dart';

class SearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final Future<void> Function(String) onSearch;
  final void Function() onSubmitted;
  final TextInputAction textInputAction;
  final bool autofocus;
  final bool clearOnSubmit;
  final InputDecoration decoration;

  const SearchTextField({
    Key key,
    @required this.controller,
    @required this.onSearch,
    this.onSubmitted,
    this.textInputAction,
    this.autofocus = false,
    this.clearOnSubmit = true,
    this.decoration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onSearch,
      textInputAction: textInputAction ?? TextInputAction.done,
      onEditingComplete: clearOnSubmit ? () => onSearch('') : null,
      onSubmitted: onSubmitted != null ? (_) => onSubmitted() : null,
      autofocus: autofocus,
      decoration: decoration?.applyDefaults(InputDecorationTheme(
            border: const OutlineInputBorder(),
            fillColor: Theme.of(context).scaffoldBackgroundColor,
          )) ??
          InputDecoration(
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.search),
            suffix: IconButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  onSearch('');
                }
                FocusScope.of(context).unfocus();
              },
              icon: const Icon(
                Icons.close,
                color: Colors.grey,
              ),
            ),
            labelText: AppLocalizations.of(context).searchHint,
          ),
    );
  }
}