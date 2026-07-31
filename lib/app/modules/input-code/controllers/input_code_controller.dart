// ignore_for_file: unnecessary_null_comparison
import 'package:get/get.dart';
import 'package:flutter/widgets.dart';
import 'package:hartono_queueing/app/routes/app_pages.dart';
import 'package:hartono_queueing/app/widgets/notification.dart';
import 'package:hartono_queueing/app/service/local_service.dart';

class InputCodeController extends GetxController with LocalService {
  late String inputCode;
  late bool isAvailable;
  bool isLoading = false;
  TextEditingController inputCodeController = TextEditingController();

  @override
  void onInit() async {
    super.onInit();
    isLoading = true;
    update();
    await loadExistingCode();
    await handleCode();
    await handleDirection();
    isLoading = false;
    update();
  }

  Future<void> loadExistingCode() async {
    try {
      inputCode = await getCode();
    } catch (e) {
      inputCode = "";
    }
  }

  Future<void> handleCode() async {
    if (inputCode == null || inputCode.isEmpty) {
      isAvailable = false;
    } else {
      isAvailable = true;
    }
  }

  Future<void> handleDirection() async {
    if (isAvailable == true) {
      Get.offNamed(Routes.HOME);
    } else {
      return;
    }
  }

  Future<void> doSubmitCode({String? inputedCode}) async {
    isLoading = true;
    update();
    FocusManager.instance.primaryFocus?.unfocus();
    if (inputedCode == null || inputedCode.isEmpty) {
      NotificationWidgets.notification(
        message: "Harap masukan kode",
        proceedButton: () => Get.back(),
      );
    } else {
      inputCodeController.clear();
      update();
      await saveCode(inputedCode.toUpperCase());
      Get.toNamed(Routes.HOME);
    }
    isLoading = false;
    update();
  }

  // @override
  // void onReady() {
  //   super.onReady();
  // }

  // @override
  // void onClose() {
  //   super.onClose();
  // }
}
