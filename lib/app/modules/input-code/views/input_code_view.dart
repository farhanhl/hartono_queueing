import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../controllers/input_code_controller.dart';
import 'package:hartono_queueing/app/theme/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hartono_queueing/app/widgets/loading_animation.dart';

class InputCodeView extends GetView<InputCodeController> {
  const InputCodeView({super.key});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<InputCodeController>(
      init: InputCodeController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: shadowColor,
          body: SafeArea(
            child: controller.isLoading == true
                ? LoadingAnimationWidgets.loadingAnimation(
                    color: Colors.black,
                    size: 100.sp,
                  )
                : controller.isAvailable == false
                    ? Container(
                        width: Get.width.w,
                        height: Get.height.h / 4,
                        padding: EdgeInsets.all(16.sp),
                        margin: EdgeInsets.only(
                          left: 16.w,
                          right: 16.w,
                          top: 80.h,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          color: lightColor,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Masukan Kode',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18.sp,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            TextFormField(
                              controller: controller.inputCodeController,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.done,
                              textCapitalization: TextCapitalization.characters,
                              style: TextStyle(fontSize: 14.sp),
                              decoration: InputDecoration(
                                fillColor: lightColor,
                                hintText: "Kode",
                                hintStyle: TextStyle(
                                  color: const Color(0xFFb2b7bf),
                                  fontSize: 14.sp,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.r),
                                  borderSide: BorderSide(
                                    width: 1.w,
                                    color: shadowColor,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.r),
                                  borderSide: BorderSide(
                                    width: 1.w,
                                    color: shadowColor,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.r),
                                  borderSide: BorderSide(
                                    width: 1.w,
                                    color: shadowColor,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          WidgetStateProperty.all<Color?>(
                                        primaryColor,
                                      ),
                                    ),
                                    onPressed: () => controller.doSubmitCode(
                                      inputedCode:
                                          controller.inputCodeController.text,
                                    ),
                                    child: Text(
                                      "Simpan",
                                      style: TextStyle(
                                        color: lightColor,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
