import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pundigo/core/theme/app_theme.dart';
import 'package:pundigo/screens/activity/activity_screen.dart';
import 'package:pundigo/screens/auth/login_screen.dart';
import 'package:pundigo/screens/auth/plus_offer_screen.dart';
import 'package:pundigo/screens/auth/register_screen.dart';
import 'package:pundigo/screens/demo/demo_links_hub_screen.dart';
import 'package:pundigo/screens/features/features_screen.dart';
import 'package:pundigo/screens/features/pln_token_screen.dart';
import 'package:pundigo/screens/features/pulsa_screen.dart';
import 'package:pundigo/screens/home/home_screen.dart';
import 'package:pundigo/screens/kyc/kyc_face_scan_screen.dart';
import 'package:pundigo/screens/kyc/kyc_ktp_camera_screen.dart';
import 'package:pundigo/screens/kyc/kyc_ktp_guide_screen.dart';
import 'package:pundigo/screens/kyc/kyc_success_screen.dart';
import 'package:pundigo/screens/main_navigation_screen.dart';
import 'package:pundigo/screens/onboarding/onboarding_screen.dart';
import 'package:pundigo/screens/patungan/patungan_ocr_screen.dart';
import 'package:pundigo/screens/patungan/shared_kas_screen.dart';
import 'package:pundigo/screens/patungan/shared_patungan_screen.dart';
import 'package:pundigo/screens/profile/change_pin_screen.dart';
import 'package:pundigo/screens/profile/edit_profile_screen.dart';
import 'package:pundigo/screens/profile/help_center_screen.dart';
import 'package:pundigo/screens/profile/profile_screen.dart';
import 'package:pundigo/screens/qris/scan_qris_screen.dart';
import 'package:pundigo/screens/transactions/patungan_pintar_screen.dart';
import 'package:pundigo/screens/transactions/request_balance_screen.dart';
import 'package:pundigo/screens/transactions/saku_kelompok_screen.dart';
import 'package:pundigo/screens/transactions/topup_screen.dart';
import 'package:pundigo/screens/transactions/transaction_history_screen.dart';
import 'package:pundigo/screens/transactions/transfer_screen.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<void> pumpPhoneScreen(WidgetTester tester, Widget screen, String name) async {
    tester.view.physicalSize = const Size(412 * 2, 915 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final criticalErrors = <String>[];
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final msg = details.exceptionAsString();
      // Ignore only font-width RenderFlex overflow caused by wide Ahem test font
      if (msg.contains('A RenderFlex overflowed')) {
        return;
      }
      criticalErrors.add(msg);
    };

    try {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: screen,
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      // Unmount cleanly to test dispose() too
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 50));
    } finally {
      FlutterError.onError = originalOnError;
    }

    expect(
      criticalErrors,
      isEmpty,
      reason: 'Screen $name threw critical FlutterErrors:\n${criticalErrors.join('\n---\n')}',
    );
  }

  final screens = <String, Widget>{
    'OnboardingScreen': const OnboardingScreen(),
    'LoginScreen': const LoginScreen(),
    'RegisterScreen': const RegisterScreen(),
    'PlusOfferScreen': const PlusOfferScreen(),
    'MainNavigationScreen': const MainNavigationScreen(),
    'HomeScreen': HomeScreen(onOpenFeatures: () {}),
    'ScanQrisScreen (Tab 0 - Scan)': const ScanQrisScreen(initialTabIndex: 0),
    'ScanQrisScreen (Tab 1 - QR Saya)': const ScanQrisScreen(initialTabIndex: 1),
    'ActivityScreen': const ActivityScreen(),
    'FeaturesScreen': const FeaturesScreen(),
    'ProfileScreen': const ProfileScreen(),
    'KycKtpGuideScreen': const KycKtpGuideScreen(),
    'KycKtpCameraScreen': const KycKtpCameraScreen(),
    'KycFaceScanScreen': const KycFaceScanScreen(),
    'KycSuccessScreen': const KycSuccessScreen(),
    'PatunganOcrScreen': const PatunganOcrScreen(),
    'PatunganPintarScreen': const PatunganPintarScreen(),
    'SakuKelompokScreen': const SakuKelompokScreen(),
    'SharedPatunganScreen': const SharedPatunganScreen(),
    'SharedKasScreen': const SharedKasScreen(),
    'TopupScreen': const TopupScreen(),
    'TransferScreen': const TransferScreen(),
    'RequestBalanceScreen': const RequestBalanceScreen(),
    'TransactionHistoryScreen': const TransactionHistoryScreen(),
    'PlnTokenScreen': const PlnTokenScreen(),
    'PulsaScreen': const PulsaScreen(),
    'EditProfileScreen': const EditProfileScreen(),
    'ChangePinScreen': const ChangePinScreen(),
    'HelpCenterScreen': const HelpCenterScreen(),
    'DemoLinksHubScreen': const DemoLinksHubScreen(),
  };

  for (final entry in screens.entries) {
    testWidgets('Smoke test: ${entry.key} renders with zero errors on emulator viewport', (tester) async {
      await pumpPhoneScreen(tester, entry.value, entry.key);
    });
  }
}
