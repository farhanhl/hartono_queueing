import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
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
import 'package:hartono_queueing/app/core/provider/api.dart';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';

class HomeController extends GetxController with LocalService {
  late String code;
  late String webUrl;
  final HomeServices services;
  bool isLoading = false;
  ConfigModel configModel = ConfigModel();
  late InAppWebViewController webViewController;
  PusherChannelsClient? pusherClient;
  Channel? pusherChannel;
  StreamSubscription? _eventSubscription;
  StreamSubscription? _connectionSubscription;
  MessageInfoDTO messageInfo = MessageInfoDTO();
  String url = 'https://storage.apk.live/com.google.android.tts--210361237.apk';
  bool isPusherInitialized = false;
  bool isTtsReady = false;
  Timer? _ttsRetryTimer;
  FlutterTts? _flutterTts;

  HomeController(this.services);

  @override
  void onInit() {
    super.onInit();
    _initializeUntilSuccess();
  }

  @override
  void onReady() {
    super.onReady();
    _showTtsNotice();
  }

  void _showTtsNotice() {
    Future.delayed(const Duration(seconds: 3), () {
      if (isTtsReady) return;
      Get.defaultDialog(
        title: "TTS Tidak Tersedia",
        middleText:
            "text-to-speech tidak ditemukan di device ini. Suara antrian tidak akan berbunyi.",
        textConfirm: "Buka Settings",
        textCancel: "Nanti Saja",
        confirmTextColor: const Color(0xFFFFFFFF),
        buttonColor: const Color(0xFF1976D2),
        onConfirm: () {
          openTTSSettings();
          Get.back();
        },
        onCancel: () {},
      );
    });
  }

  void _initializeUntilSuccess() async {
    log('_initializeUntilSuccess: mulai');
    isLoading = true;
    update();

    while (true) {
      try {
        log('_initializeUntilSuccess: mengambil kode dari local storage...');
        code = await getCode().timeout(const Duration(seconds: 5));
        log('_initializeUntilSuccess: kode didapatkan = "$code"');

        log('_initializeUntilSuccess: mengambil config dari server...');
        await getAppConfig().timeout(const Duration(seconds: 15));
        log('_initializeUntilSuccess: config didapatkan');

        log('_initializeUntilSuccess: inisialisasi selesai');
        break;
      } catch (e) {
        log('_initializeUntilSuccess: gagal - $e');
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    isLoading = false;
    update();
    log('_initializeUntilSuccess: selesai, loading = false');

    initPusher();
    initTtsInBackground();
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
      log('getAppConfig: requesting $configBaseUrl/display/queue/config');
      configModel = await services.getAppConfig();
      log('getAppConfig: response status = ${configModel.status}');
      if (configModel.isNotEmpty()) {
        webUrl = '${configModel.result?.url}/$code';
        log('getAppConfig: webUrl = "$webUrl"');
      }
    } catch (e) {
      log('getAppConfig: error - $e');
      rethrow;
    }
  }

  void initTtsInBackground() async {
    log('initTtsInBackground: mulai');
    try {
      _flutterTts = FlutterTts();

      log('initTtsInBackground: setEngine("com.google.android.tts")');
      await _flutterTts!.setEngine("com.google.android.tts").timeout(
            const Duration(seconds: 5),
            onTimeout: () => log('initTtsInBackground: setEngine timeout'),
          );

      log('initTtsInBackground: setLanguage("in")');
      await _flutterTts!.setLanguage("in").timeout(
            const Duration(seconds: 5),
            onTimeout: () => log('initTtsInBackground: setLanguage timeout'),
          );

      await _flutterTts!.setSpeechRate(0.3);
      await _flutterTts!.setVolume(1.0);
      await _flutterTts!.setPitch(1.0);

      log('initTtsInBackground: test speak...');
      await _flutterTts!.speak("TTS aktif").timeout(
            const Duration(seconds: 5),
            onTimeout: () => log('initTtsInBackground: test speak timeout'),
          );

      isTtsReady = true;
      _ttsRetryTimer?.cancel();
      log('initTtsInBackground: selesai, isTtsReady = true');
    } catch (e) {
      isTtsReady = false;
      log('initTtsInBackground: gagal - $e');
      _flutterTts = null;
      _startTtsRetryTimer();
    }
  }

  void _startTtsRetryTimer() {
    if (_ttsRetryTimer != null && _ttsRetryTimer!.isActive) return;
    log('_startTtsRetryTimer: retry setiap 30 detik');
    _ttsRetryTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      log('_startTtsRetryTimer: mencoba init TTS lagi...');
      initTtsInBackground();
    });
  }

  Future<void> speak(String text) async {
    if (!isTtsReady || _flutterTts == null) {
      log('speak: TTS belum siap, skip');
      return;
    }

    try {
      log('speak: speaking "$text"');
      await _flutterTts!.speak(text);
      log('speak: selesai');
    } catch (e) {
      log('speak: error - $e');
    }
  }

  void initPusher() async {
    if (isPusherInitialized) {
      log('initPusher: sudah diinisialisasi, skip');
      return;
    }

    try {
      log('initPusher: menginisialisasi pusher...');
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
      log('initPusher: selesai');
    } catch (e) {
      log('initPusher: error - $e');
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

  Future<void> checkAvailableLanguages() async {
    try {
      final tts = _flutterTts ?? FlutterTts();

      log('checkAvailableLanguages: getEngines...');
      dynamic engines = await tts.getEngines.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          log('checkAvailableLanguages: getEngines timeout');
          return null;
        },
      );
      log('checkAvailableLanguages: engines = $engines');

      log('checkAvailableLanguages: getLanguages...');
      dynamic languages = await tts.getLanguages.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          log('checkAvailableLanguages: getLanguages timeout');
          return null;
        },
      );
      log('checkAvailableLanguages: languages = $languages');

      String engineInfo = engines == null
          ? "Tidak dapat mengambil data engine"
          : "Engine: ${engines is List ? engines.join(', ') : engines}";

      String langInfo;
      if (languages == null) {
        langInfo = "Tidak dapat mengambil data bahasa";
      } else if (languages is List && languages.isEmpty) {
        langInfo = "Tidak ada bahasa tersedia";
      } else {
        langInfo = (languages as List).join('\n');
      }

      Get.defaultDialog(
        title: "Info TTS",
        middleText: "$engineInfo\n\nBahasa tersedia:\n$langInfo",
        textConfirm: "OK",
        confirmTextColor: const Color(0xFFFFFFFF),
        buttonColor: const Color(0xFF1976D2),
        onConfirm: () => Get.back(),
      );
    } catch (e) {
      log('checkAvailableLanguages: error - $e');
      Get.defaultDialog(
        title: "Error",
        middleText: "Gagal cek TTS: $e",
        textConfirm: "OK",
        confirmTextColor: const Color(0xFFFFFFFF),
        buttonColor: const Color(0xFFD32F2F),
        onConfirm: () => Get.back(),
      );
    }
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
    _ttsRetryTimer?.cancel();
    if (_flutterTts != null) {
      await _flutterTts!
          .stop()
          .timeout(const Duration(seconds: 3), onTimeout: () {});
    }
    await disposePusher();
    super.onClose();
  }
}
