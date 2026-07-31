import 'package:dio/dio.dart';

const configBaseUrl = "https://api-hartono.dmmrnd.id";

class Api extends Interceptor {
  final dioConfig = Dio(
    BaseOptions(
      baseUrl: configBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      contentType: Headers.jsonContentType,
    ),
  );

  Future<Response> getAppConfig() async {
    return dioConfig.get("/display/queue/config");
  }
}
