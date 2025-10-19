import 'package:dio/dio.dart';
import 'package:smartroots/core/config.dart' show Settings;
import 'dart:convert';

class APIService {
  final Dio apiClient = Dio(
    BaseOptions(
      baseUrl: Settings.apiBaseUrl,
      headers: {
        'Authorization':
            'Basic ${base64Encode(utf8.encode('${Settings.apiAuthorizationUsername}:${Settings.apiAuthorizationPassword}'))}',
      },
      connectTimeout: Duration(seconds: Settings.apiConnectTimeout),
      receiveTimeout: Duration(seconds: Settings.apiReceiveTimeout),
    ),
  );
}
