import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'services/notes_database.dart';
import 'screens/folders_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotesDatabase.init();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const GoldenNotesApp());
}

class GoldenNotesApp extends StatelessWidget {
  const GoldenNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Golden Notes',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkGold,
      darkTheme: AppTheme.darkGold,
      themeMode: ThemeMode.dark,
      home: const FoldersScreen(),
    );
  }
}
