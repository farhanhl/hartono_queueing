import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hartono_queueing/app/core/provider/api.dart';
import 'package:hartono_queueing/app/modules/home/services/home_service.dart';
import '../controllers/home_controller.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hartono_queueing/app/widgets/loading_animation.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(HomeServices(Get.find<Api>())),
      builder: (context) {
        return Scaffold(
          floatingActionButton: SpeedDial(
            icon: Icons.more_vert,
            backgroundColor: const Color(0XFFFDCB00),
            foregroundColor: const Color(0XFF323840),
            children: [
              SpeedDialChild(
                child: const Icon(Icons.change_circle),
                label: 'Ganti Kode',
                backgroundColor: Colors.green,
                onTap: () => controller.handleChangeCode(),
              ),
              SpeedDialChild(
                child: const Icon(Icons.refresh),
                label: 'Segarkan Halaman',
                backgroundColor: const Color(0XFF1C8BCA),
                onTap: () => controller.webViewController.reload(),
              ),
              SpeedDialChild(
                child: const Icon(Icons.change_circle),
                label: 'Tes Suara',
                backgroundColor: const Color(0XFF194798),
                onTap: () => controller.speak("Tes suara satu, dua, tiga"),
              ),
              SpeedDialChild(
                child: const Icon(Icons.settings),
                label: 'Pengaturan TTS',
                backgroundColor: const Color(0XFFCAE5F6),
                onTap: () => controller.openTTSSettings(),
              ),
              SpeedDialChild(
                child: const Icon(Icons.download),
                label: 'Unduh TTS',
                backgroundColor: Colors.white,
                onTap: () => controller.downloadTTSEngine(),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async => await controller.refreshPage(),
            child: controller.isLoading == true
                ? LoadingAnimationWidgets.loadingAnimation(
                    color: Colors.black,
                    size: 100.sp,
                  )
                : InAppWebView(
                    initialUrlRequest: URLRequest(
                      url: WebUri(controller.webUrl),
                    ),
                    onReceivedServerTrustAuthRequest:
                        (controller, challenge) async {
                      return ServerTrustAuthResponse(
                        action: ServerTrustAuthResponseAction.PROCEED,
                      );
                    },
                    onWebViewCreated: (controller) {
                      this.controller.webViewController = controller;
                    },
                    initialSettings: InAppWebViewSettings(
                      useHybridComposition: true,
                      javaScriptEnabled: true,
                      mediaPlaybackRequiresUserGesture: false,
                      cacheEnabled: false,
                      clearCache: true,
                    ),
                    onPermissionRequest: (controller, permissionRequest) async {
                      return Future.value(
                        PermissionResponse(
                          resources: permissionRequest.resources,
                          action: PermissionResponseAction.GRANT,
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
