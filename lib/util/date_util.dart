import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateUtil {
  final BuildContext _context;
  DateUtil(this._context);

  String formatDateTimeToLocalString(DateTime dateTime) {
    final locale = Localizations.localeOf(_context);
    final formattedDate =
        DateFormat.yMd(locale.toString()).add_Hm().format(dateTime);

    return formattedDate;
  }
}
