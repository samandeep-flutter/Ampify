import 'dart:math';
import 'package:ampify/data/utils/dimens.dart';
import 'package:flutter/material.dart';

sealed class Utils {
  static TextStyle get defTitleStyle {
    return const TextStyle(
      fontSize: Dimens.fontExtraLarge,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    );
  }

  static TextStyle titleTextStyle([Color? color]) {
    return TextStyle(
      fontSize: Dimens.fontTitle,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  static String generateString(int length) {
    String result = '';
    const char = 'qwertyuioplkjhgfdsazxcvbnm';

    for (int i = 0; i < length; i++) {
      result += char[Random().nextInt(char.length)];
    }
    return result;
  }

//   static String timeFromNow(DateTime? date, DateTime now) {
//     if (date == null) return '';
//     final diff = now.difference(date);
//     if (diff.inDays > 0) {
//       switch (diff.inDays) {
//         case > 364:
//           return '${(diff.inDays / 365).toStringAsFixed(1)} years ago';
//         case > 30:
//           return '${(diff.inDays / 30.416).round()} days ago';
//         case > 6:
//           return '${(diff.inDays / 7).round()} weeks ago';
//         case 1:
//           return '1 day ago';
//         default:
//           return '${diff.inDays} days ago';
//       }
//     } else if (diff.inHours > 0) {
//       return '${diff.inHours} hours ago';
//     } else if (diff.inMinutes > 0) {
//       return '${diff.inMinutes} min ago';
//     }

//     return 'Just now';
//   }
}
