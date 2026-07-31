import 'package:get/get.dart';
import 'package:hartono_queueing/app/core/provider/api.dart';
import 'package:hartono_queueing/app/modules/home/services/home_service.dart';

import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(HomeServices(Get.find<Api>())),
    );
  }
}
