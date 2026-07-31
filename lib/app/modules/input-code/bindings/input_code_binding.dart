import 'package:get/get.dart';

import '../controllers/input_code_controller.dart';

class InputCodeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InputCodeController>(
      () => InputCodeController(),
    );
  }
}
