import 'package:dio/dio.dart';

class NetworkClient {
  static const String _localhost = 'http://localhost:8080';
  // TODO: Replace with your machine's local IP for physical device testing
  static const String _physicalDeviceUrl = 'http://192.168.1.5:8080';

  late final Dio dio;

  NetworkClient({bool useLocalhost = true}) {
    dio = Dio(
      BaseOptions(
        baseUrl: useLocalhost ? _localhost : _physicalDeviceUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  void toggleBaseUrl({required bool useLocalhost}) {
    dio.options.baseUrl = useLocalhost ? _localhost : _physicalDeviceUrl;
  }
}
