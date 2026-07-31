import 'dart:ui';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hartono_queueing/app/theme/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationWidgets {
  static Future<dynamic> notification({
    required String message,
    required VoidCallback? proceedButton,
  }) {
    return Get.defaultDialog(
      barrierDismissible: false,
      title: "",
      content: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 0.8, sigmaY: 0.8),
            child: Container(
              color: darkColor.withOpacity(1),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18.sp),
                ),
                SizedBox(
                  height: 30.h,
                ),
                ElevatedButton(
                  onPressed: proceedButton ?? () {},
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color?>(
                      primaryColor,
                    ),
                  ),
                  child: const Text(
                    "Tutup",
                    style: TextStyle(
                      color: lightColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
