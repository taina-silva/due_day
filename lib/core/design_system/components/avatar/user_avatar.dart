import 'dart:convert';

import 'package:flutter/material.dart';

/// Renders a user's profile photo (Base64 data URI or `http(s)` URL) clipped
/// to a circle, or [fallback] when there is no photo to show.
class UserAvatar extends StatelessWidget {
  final double size;
  final String? photoUrl;
  final Widget fallback;

  const UserAvatar({
    required this.size,
    required this.fallback,
    this.photoUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;
    if (url == null) return fallback;

    if (url.startsWith('data:image')) {
      final base64Data = url.substring(url.indexOf(',') + 1);
      return ClipOval(
        child: Image.memory(
          base64Decode(base64Data),
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return ClipOval(
        child: Image.network(url, width: size, height: size, fit: BoxFit.cover),
      );
    }

    return fallback;
  }
}
