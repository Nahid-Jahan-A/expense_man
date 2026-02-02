import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'firebase_options.dart';
import 'core/di/service_locator.dart';
import 'features/expense/data/models/expense_model.dart';
import 'features/category/data/models/category_model.dart';
import 'features/settings/data/models/settings_model.dart';
import 'app/app.dart';

void main() async {
  // Preserve native splash screen until initialization is complete
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(ExpenseModelAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(SettingsModelAdapter());

  // Initialize dependencies
  await initializeDependencies();

  // Remove native splash - Flutter is ready
  FlutterNativeSplash.remove();

  runApp(const ExpenseManagerApp());
}
