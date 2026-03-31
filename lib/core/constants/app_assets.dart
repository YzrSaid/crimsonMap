class AppAssets {
  AppAssets._();

  // Base paths
  static const String _images = 'assets/images';
  static const String _icons = 'assets/icons';
  static const String _animations = 'assets/animations';

  // Images
  static const String logo = '$_images/logo.png';
  static const String logoFull = '$_images/logo_full.png';
  static const String campusMap = '$_images/campus_map.png';
  static const String wmsuCrest = '$_images/wmsu_crest.png';

  // Onboarding
  static const String onboarding1 = '$_images/onboarding_1.png';
  static const String onboarding2 = '$_images/onboarding_2.png';
  static const String onboarding3 = '$_images/onboarding_3.png';

  // Icons
  static const String iconAr = '$_icons/ic_ar.svg';
  static const String iconQr = '$_icons/ic_qr.svg';
  static const String iconMap = '$_icons/ic_map.svg';
  static const String iconBuilding = '$_icons/ic_building.svg';

  // Animations (Lottie)
  static const String splashAnimation = '$_animations/splash.json';
  static const String loadingAnimation = '$_animations/loading.json';
  static const String arCalibration = '$_animations/ar_calibration.json';
  static const String emptyState = '$_animations/empty_state.json';
}
