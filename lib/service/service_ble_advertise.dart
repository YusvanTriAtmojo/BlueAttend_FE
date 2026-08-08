import 'package:flutter/services.dart';

class ServiceBleAdvertiser {
  static const MethodChannel _channel = MethodChannel('ble_advertiser');

  static Future<void> startAdvertising() async {
    await _channel.invokeMethod('startAdvertising');
  }

  static Future<void> stopAdvertising() async {
    await _channel.invokeMethod('stopAdvertising');
  }
}