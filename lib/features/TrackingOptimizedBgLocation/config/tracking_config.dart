class TrackingConfig {
  //  DEBUG MODE (change to false later)
  static const bool debugMode = true;

  // Stop detection
  static double stopRadiusMeters =
  debugMode ? 100 : 100;

  static Duration stopTimeThreshold =
  debugMode ? Duration(minutes: 15) : Duration(minutes: 15);
}
