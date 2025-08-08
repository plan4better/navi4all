import 'package:dio/dio.dart';
import 'package:navi4all/core/config.dart' show Settings;

class APIService {
  final Dio apiClient = Dio(
    BaseOptions(
      baseUrl: Settings.apiBaseUrl,
      connectTimeout: Duration(seconds: Settings.apiConnectTimeout),
      receiveTimeout: Duration(seconds: Settings.apiReceiveTimeout),
    ),
  );
}
