/// Application-wide spacing constants for consistent padding, margins, and gaps
/// Uses an 8px baseline for Material Design 3 consistency

class AppSpacing {
  // Extra small - 4px (half baseline)
  static const double xs = 4.0;

  // Small - 8px (baseline)
  static const double sm = 8.0;

  // Medium - 16px (2x baseline)
  static const double md = 16.0;

  // Large - 24px (3x baseline)
  static const double lg = 24.0;

  // Extra large - 32px (4x baseline)
  static const double xl = 32.0;

  // 2X extra large - 40px (5x baseline)
  static const double xxl = 40.0;

  // 3X extra large - 48px (6x baseline)
  static const double xxxl = 48.0;

  // Screen padding - standard horizontal padding for content
  static const double screenPadding = 16.0;

  // Card/Container padding
  static const double cardPadding = 16.0;

  // Form field spacing - between input fields
  static const double formFieldSpacing = 16.0;

  // Section spacing - between major sections
  static const double sectionSpacing = 24.0;

  // List/Grid item spacing
  static const double listItemSpacing = 8.0;

  // Button spacing - horizontal spacing for button groups
  static const double buttonSpacing = 12.0;

  // Dialog content padding
  static const double dialogContentPadding = 24.0;

  // Header padding
  static const double headerPadding = 16.0;

  // Footer padding
  static const double footerPadding = 16.0;

  // AppBar padding (handled by Material, but reference value)
  static const double appBarHeight = 56.0;

  // Navigation drawer width
  static const double drawerWidth = 280.0;
}

/// Border radius constants for consistency
class AppBorderRadius {
  // Small - subtle corners
  static const double sm = 4.0;

  // Medium - standard corners
  static const double md = 8.0;

  // Large - card corners
  static const double lg = 12.0;

  // Extra large - modal corners
  static const double xl = 16.0;

  // Full circle
  static const double circle = 50.0;
}

/// Elevation/Shadow constants for z-index hierarchy
class AppElevation {
  // Minimal elevation - subtle shadow
  static const double minimal = 1.0;

  // Low elevation - cards, buttons
  static const double low = 2.0;

  // Medium elevation - hovered cards, dialogs
  static const double medium = 4.0;

  // High elevation - floating action buttons, overlays
  static const double high = 8.0;

  // Extra high elevation - modals, dropdown menus
  static const double extraHigh = 12.0;
}

/// Animation duration constants for consistency
class AppDuration {
  // Quick interaction feedback
  static const Duration quick = Duration(milliseconds: 150);

  // Standard animation
  static const Duration standard = Duration(milliseconds: 300);

  // Slow animation (entrances/exits)
  static const Duration slow = Duration(milliseconds: 500);

  // Very slow animation (complex transitions)
  static const Duration verySlow = Duration(milliseconds: 800);
}
