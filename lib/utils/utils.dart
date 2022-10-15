import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:selvam_broilers/utils/colors.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'flags.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

void showToast({required String message, Color? color, bool? isError}) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP_RIGHT,
      timeInSecForIosWeb: 3,
      backgroundColor: color ?? primary,
      textColor: white,
      fontSize: 16.0,
      webBgColor: isError ?? false
          ? 'linear-gradient(to right, #ff0000, #ff0000)'
          : 'linear-gradient(to right, #292A31, #292A31)');
}

Future<PlatformFile?> showImagePicker([bool imageOnly = false]) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions:
        imageOnly ? ['png', 'jpg', 'jpeg'] : ['pdf', 'png', 'jpg', 'jpeg'],
  );
  return result!.files.first;
}

int daysBetween(DateTime from, DateTime to) {
  from = DateTime(from.year, from.month, from.day);
  to = DateTime(to.year, to.month, to.day);
  return (to.difference(from).inHours / 24).round();
}

String getPaymentText(List<PaymentMode> list) {
  String text = '';
  if (list.contains(PaymentMode.CASH)) {
    text += 'Cash ';
  }
  if (list.contains(PaymentMode.CHEQUE)) {
    text += 'Cheque ';
  }
  if (list.contains(PaymentMode.GPAY)) {
    text += 'UPI ';
  }
  return text.trim().replaceAll(' ', ', ');
}

String getFormattedDate(DateTime? date) {
  if (date == null) return '';
  return DateFormat('dd-MM-yyyy').format(date);
}

String getFormattedDateTime(DateTime date, String format) {
  return DateFormat(format).format(date);
}

DateTime getDate(String date) {
  return DateFormat('dd-MM-yyyy').parse(date);
}

String getDateFilterText(DateFilter filter) {
  switch (filter) {
    case DateFilter.TODAY:
      return 'Today';

    case DateFilter.THIS_WEEK:
      return 'This Week';

    case DateFilter.LAST_SEVEN_DAYS:
      return 'Last 7 days';

    case DateFilter.THIS_MONTH:
      return 'This month';

    case DateFilter.LAST_30_DAYS:
      return 'Last 30 days';

    case DateFilter.LAST_6_MONTHS:
      return 'Last 6 months';

    case DateFilter.ALL:
      return 'All';
    case DateFilter.CUSTOM_RANGE:
      return 'Custom Range';
  }
}

Future<PdfFont> getFont(TextStyle style) async {
  //Get the external storage directory
  // Directory directory = await getApplicationSupportDirectory();
  //Create an empty file to write the font data
  final font = await rootBundle.load("assets/fonts/Lato-Regular.ttf");
  List<int>? fontBytes = font.buffer.asUint8List();
  return PdfTrueTypeFont(fontBytes, 12);
}

bool isTab() {
  final isWebMobile = kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  final data = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
  return isWebMobile && data.size.shortestSide >= 600;
}
