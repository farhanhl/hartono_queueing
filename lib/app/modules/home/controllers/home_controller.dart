import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hartono_queueing/app/modules/home/models/config_model.dart';
import 'package:hartono_queueing/app/modules/home/services/home_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:hartono_queueing/app/routes/app_pages.dart';
import 'package:hartono_queueing/app/data/message_info.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hartono_queueing/app/service/local_service.dart';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';

class HomeController extends GetxController with LocalService {
  late String code;
  late String webUrl;
  final HomeServices services;
  bool isLoading = false;
  ConfigModel configModel = ConfigModel();
  final FlutterTts flutterTts = FlutterTts();
  late InAppWebViewController webViewController;
  PusherChannelsClient? pusherClient;
  Channel? pusherChannel;
  StreamSubscription? _eventSubscription;
  StreamSubscription? _connectionSubscription;
  MessageInfoDTO messageInfo = MessageInfoDTO();
  String url = 'https://storage.apk.live/com.google.android.tts--210361237.apk';
  bool isPusherInitialized = false;

  HomeController(this.services);

  @override
  void onInit() {
    super.onInit();
    _initializeUntilSuccess();
  }

  void _initializeUntilSuccess() async {
    isLoading = true;
    update();

    while (true) {
      try {
        await flutterTts.stop();
        code = await getCode();
        await getAppConfig();
        break;
      } catch (e) {
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    isLoading = false;
    update();
  }

  Future<void> disposePusher() async {
    try {
      _eventSubscription?.cancel();
      _connectionSubscription?.cancel();
      pusherChannel?.unsubscribe();
      pusherClient?.dispose();
    } catch (_) {}

    pusherClient = null;
    pusherChannel = null;
    _eventSubscription = null;
    _connectionSubscription = null;
    isPusherInitialized = false;
  }

  Future<void> getAppConfig() async {
    try {
      configModel = await services.getAppConfig();
      if (configModel.isNotEmpty()) {
        await initializeTts();
        await initPusher();
        webUrl = '${configModel.result?.url}$code';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> initializeTts() async {
    try {
      await flutterTts.awaitSpeakCompletion(true);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> speak(String text) async {
    try {
      bool isAvailable = await flutterTts.isLanguageAvailable("in-ID").timeout(
            const Duration(seconds: 5),
            onTimeout: () => false,
          );

      if (isAvailable) {
        await flutterTts.setLanguage("in-ID");
        await flutterTts.setSpeechRate(0.3);
        await flutterTts.setVolume(1.0);
        await flutterTts.setPitch(1.0);
        await flutterTts.speak(text);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> initPusher() async {
    if (isPusherInitialized) {
      return;
    }

    try {
      final options = PusherChannelsOptions.fromCluster(
        scheme: 'wss',
        cluster: configModel.result?.pusher?.cluster ?? "",
        key: configModel.result?.pusher?.appKey ?? "",
        host: 'pusher.com',
        port: 443,
        shouldSupplyMetadataQueries: true,
        metadata: const PusherChannelsOptionsMetadata.byDefault(),
      );

      pusherClient = PusherChannelsClient.websocket(
        options: options,
        connectionErrorHandler: (exception, trace, refresh) {
          log("Pusher connection error: $exception");
          refresh();
        },
        minimumReconnectDelayDuration: const Duration(seconds: 1),
      );

      pusherChannel = pusherClient!.publicChannel('queue-channel');

      _connectionSubscription =
          pusherClient!.onConnectionEstablished.listen((_) {
        log("Pusher connection established");
        pusherChannel!.subscribeIfNotUnsubscribed();
      });

      _eventSubscription = pusherChannel!.bindToAll().listen((event) {
        _handleEvent(event.name, event.data);
      });

      await pusherClient!.connect();

      isPusherInitialized = true;
    } catch (e) {
      rethrow;
    }
  }

  void _handleEvent(String eventName, dynamic data) {
    try {
      Map<String, dynamic> decodedJson;
      if (data is String) {
        decodedJson = jsonDecode(data);
      } else if (data is Map) {
        decodedJson = Map<String, dynamic>.from(data);
      } else {
        return;
      }

      messageInfo = MessageInfoDTO.fromJson(decodedJson);
      String? queueNo = messageInfo.message?.queueNo;
      String? code = messageInfo.message?.branch?.code;
      if (queueNo != null && code == this.code) {
        speak("Nomor antrian $queueNo Harap memasuki booth");
      }
    } catch (e) {
      log("Error handling pusher event: $e");
    }
  }

  Future<void> openTTSSettings() async {
    const intent = AndroidIntent(
      action: 'com.android.settings.TTS_SETTINGS',
    );
    await intent.launch();
  }

  Future<void> downloadTTSEngine() async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {}
  }

  Future<void> refreshPage() async {
    await webViewController.reload();
    update();
  }

  Future<void> handleChangeCode() async {
    await deleteCode();
    Get.offNamed(Routes.INPUT_CODE);
  }

  @override
  Future<void> onClose() async {
    await flutterTts.stop();
    await disposePusher();
    super.onClose();
  }
}
