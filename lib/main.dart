import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl_standalone.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  try {
    await dotenv.load();
  } catch (_) {}
  await PackageInfo.fromPlatform();
  if (!kIsWeb) await findSystemLocale(); //BUG in package for web?
  runApp(App());
}
