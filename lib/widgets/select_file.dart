import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kitchenowl/kitchenowl.dart';

import 'select_dialog.dart';

Future<File?> selectFile(BuildContext context) async {
  final ImagePicker _picker = ImagePicker();

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    int? i = await showDialog<int>(
      context: context,
      builder: (context) => SelectDialog(
        title: AppLocalizations.of(context)!.addRecipeToPlanner,
        cancelText: AppLocalizations.of(context)!.cancel,
        options: [
          SelectDialogOption(
            ImageSource.camera.index,
            AppLocalizations.of(context)!.camera,
            Icons.camera_alt_rounded,
          ),
          SelectDialogOption(
            ImageSource.gallery.index,
            AppLocalizations.of(context)!.gallery,
            Icons.photo_library_rounded,
          ),
        ],
      ),
    );
    if (i == null) return null;

    XFile? result = await _picker.pickImage(
      source: ImageSource.values[i],
    );
    if (result != null) {
      return File(result.path);
    }
  } else {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'],
    );
    if (result != null && result.files.first.path != null) {
      return File(result.files.first.path!);
    }
  }

  return null;
}
