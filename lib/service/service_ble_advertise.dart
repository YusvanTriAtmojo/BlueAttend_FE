import 'package:flutter/services.dart';

class ServiceBleAdvertiser {
  static const MethodChannel _channel = MethodChannel('ble_advertiser');

  static Future<void> startAdvertising(String uuid) async {
    await _channel.invokeMethod(
      'startAdvertising',
      {
        'uuid': uuid,
      },
    );
  }

  static Future<void> stopAdvertising() async {
    await _channel.invokeMethod('stopAdvertising');
  }
}