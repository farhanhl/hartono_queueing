import 'dart:io';
import 'package:get/get.dart';
import 'package:hartono_queueing/app/core/provider/api.dart';
import 'app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  await GetStorage.init();
  runApp(
    ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: "Hartono Queueing",
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          initialBinding: BindingsBuilder(() {
            Get.put(Api(), permanent: true);
          }),
        );
      },
    ),
  );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
