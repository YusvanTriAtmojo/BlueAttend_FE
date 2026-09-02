package com.example.blueattend

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "ble_advertiser"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val bleAdvertiser = BleAdvertiser(this)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "startAdvertising" -> {

                    val uuid = call.argument<String>("uuid")

                    if (uuid == null) {
                        result.error("INVALID_UUID", "UUID tidak ditemukan", null)
                        return@setMethodCallHandler
                    }

                    bleAdvertiser.startAdvertising(uuid)
                    result.success(null)
                }

                "stopAdvertising" -> {
                    bleAdvertiser.stopAdvertising()
                    result.success(null)
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}