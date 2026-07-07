import 'package:due_day/core/design_system/theme/app_typography/typography_styles.dart';

class AppTypography {
  final HeadlineStyles headline;
  final TitleStyles title;
  final BodyStyles body;
  final LabelStyles label;
  final CaptionStyles caption;

  const AppTypography()
    : headline = const HeadlineStyles(),
      title = const TitleStyles(),
      body = const BodyStyles(),
      label = const LabelStyles(),
      caption = const CaptionStyles();
}
