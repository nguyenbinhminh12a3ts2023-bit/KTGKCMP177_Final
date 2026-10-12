import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'constants/theme_colors.dart';
import 'providers/app_state.dart';
import 'screens/admin/admin_edit_exam_screen.dart';
import 'screens/admin/admin_exam_list_screen.dart';
import 'screens/admin/admin_preview_exam_screen.dart';
import 'screens/admin/admin_upload_word_screen.dart';
import 'screens/student/student_exam_detail_screen.dart';
import 'screens/student/student_exam_list_screen.dart';
import 'screens/student/student_exam_taking_screen.dart';
import 'screens/student/student_result_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const ToeicApp(),
    ),
  );
}

class ToeicApp extends StatelessWidget {
  const ToeicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hệ thống thi TOEIC Reading',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bgLight,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryTeal,
          primary: AppColors.primaryTeal,
          secondary: AppColors.primaryNavy,
          surface: AppColors.surfaceWhite,
        ),
        textTheme: GoogleFonts.interTextTheme().apply(bodyColor: AppColors.textBody,
  displayColor: AppColors.textDark,),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surfaceWhite,
          elevation: 0,
        ),
      ),
      home: const MainRouterScreen(),
    );
  }
}

class MainRouterScreen extends StatelessWidget {
  const MainRouterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    switch (state.currentScreen) {
      case ActiveScreen.adminExamList:
        return const AdminExamListScreen();
      case ActiveScreen.adminUploadWord:
        return const AdminUploadWordScreen();
      case ActiveScreen.adminPreviewExam:
        return const AdminPreviewExamScreen();
      case ActiveScreen.adminEditExam:
        return const AdminEditExamScreen();

      case ActiveScreen.studentExamList:
        return const StudentExamListScreen();
      case ActiveScreen.studentExamDetail:
        return const StudentExamDetailScreen();
      case ActiveScreen.studentExamTaking:
        return const StudentExamTakingScreen();
      case ActiveScreen.studentResult:
        return const StudentResultScreen();
    }
  }
}
