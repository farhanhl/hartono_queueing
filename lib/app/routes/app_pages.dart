import 'package:get/get.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/input-code/bindings/input_code_binding.dart';
import '../modules/input-code/views/input_code_view.dart';

// ignore_for_file: constant_identifier_names

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.INPUT_CODE;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.INPUT_CODE,
      page: () => const InputCodeView(),
      binding: InputCodeBinding(),
    ),
  ];
}
