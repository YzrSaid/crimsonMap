class AppStrings {
  AppStrings._();

  // General
  static const String loading = 'Loading...';
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String ok = 'OK';
  static const String error = 'Something went wrong.';
  static const String noInternet = 'No internet connection.';

  // Auth
  static const String signIn = 'Sign In';
  static const String signOut = 'Sign Out';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String invalidCredentials = 'Invalid email or password.';

  // Onboarding
  static const String onboardingSkip = 'Skip';
  static const String onboardingNext = 'Next';
  static const String onboardingGetStarted = "Let's Go!";

  // Navigation
  static const String navHome = 'Home';
  static const String navExplore = 'Explore';
  static const String navQrScan = 'Scan';
  static const String navAR = 'AR Nav';
  static const String navSettings = 'Settings';

  // Explore
  static const String searchHint = 'Search buildings, rooms...';
  static const String noResults = 'No results found.';

  // QR Scanner
  static const String qrScanTitle = 'Scan QR Code';
  static const String qrScanInstruction = 'Point your camera at the QR code on the marker.';

  // AR Navigation
  static const String arPermissionTitle = 'Camera Permission Required';
  static const String arPermissionBody =
      'Crimson Map needs camera access to enable AR navigation.';
  static const String arLaunching = 'Launching AR Navigation...';
  static const String arCalibrating = 'Calibrating...';

  // Settings
  static const String settingsTitle = 'Settings';
}
