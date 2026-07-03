import 'package:flutter/material.dart';

class SpacingStyles {
  const SpacingStyles();

  double get extraSmall => 2.0;
  double get small => 4.0;
  double get smallMedium => 8.0;
  double get medium => 12.0;
  double get mediumLarge => 16.0;
  double get large => 20.0;
  double get largeExtraLarge => 24.0;
  double get extraLarge => 28.0;
  double get twoExtraLarge => 36.0;
  double get twoExtraLargeMedium => 40.0;
  double get threeExtraLarge => 64.0;
  double get safeBottomNav => 120.0;

  EdgeInsets get paddingSmall => EdgeInsets.all(small);
  EdgeInsets get paddingMedium => EdgeInsets.all(medium);
  EdgeInsets get paddingLarge => EdgeInsets.all(large);
  EdgeInsets get paddingExtraLarge => EdgeInsets.all(extraLarge);

  EdgeInsets get marginSmall => EdgeInsets.all(small);
  EdgeInsets get marginMedium => EdgeInsets.all(medium);
  EdgeInsets get marginLarge => EdgeInsets.all(large);

  EdgeInsets get paddingHorizontalSmall =>
      EdgeInsets.symmetric(horizontal: small);
  EdgeInsets get paddingHorizontalLarge =>
      EdgeInsets.symmetric(horizontal: large);

  EdgeInsets get paddingVerticalSmall => EdgeInsets.symmetric(vertical: small);
  EdgeInsets get paddingVerticalLarge => EdgeInsets.symmetric(vertical: large);
}
