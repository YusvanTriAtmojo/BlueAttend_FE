package com.example.blueattend

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.bluetooth.le.AdvertiseCallback
import android.bluetooth.le.AdvertiseData
import android.bluetooth.le.AdvertiseSettings
import android.bluetooth.le.BluetoothLeAdvertiser
import android.os.ParcelUuid
import android.util.Log
import android.content.Context
import android.os.Handler
import android.os.Looper
import java.time.LocalTime
import java.util.UUID

class BleAdvertiser(private val context: Context) 
{
    companion object {
        private const val DEVICE_NAME = "UMY"

        private val SERVICE_UUID = UUID.fromString(
            "19121981-98d4-4568-6212-169eebd37705"
        )
    }

    private val bluetoothManager =
        context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager

    private val bluetoothAdapter: BluetoothAdapter =
        bluetoothManager.adapter

    private val advertiser: BluetoothLeAdvertiser? =
        bluetoothAdapter.bluetoothLeAdvertiser
    
    
    private val advertiseCallback = object : AdvertiseCallback() {

        override fun onStartSuccess(settingsInEffect: AdvertiseSettings) {
            super.onStartSuccess(settingsInEffect)

            Log.d("BLE", "Advertising berhasil dimulai")
        }

        override fun onStartFailure(errorCode: Int) {
            super.onStartFailure(errorCode)

            Log.e("BLE", "Advertising gagal : $errorCode")
        }
    }

    private val handler = Handler(Looper.getMainLooper())

    private var isAdvertising = false

    private val advertiseRunnable = object : Runnable {

        override fun run() {
            if (!isAdvertising) return
            restartAdvertising()
            handler.postDelayed(this, 5000)
        }

    }

    private fun buildSettings(): AdvertiseSettings {

        return AdvertiseSettings.Builder()
            .setAdvertiseMode(
                AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY
            )
            .setTxPowerLevel(
                AdvertiseSettings.ADVERTISE_TX_POWER_HIGH
            )
            .setConnectable(false)
            .build()
    }

   private fun buildAdvertiseData(): AdvertiseData {

        return AdvertiseData.Builder()
            .setIncludeDeviceName(false)
            .addServiceUuid(
                ParcelUuid(SERVICE_UUID)
            )
            .build()
    }

    fun startAdvertising() {

        if (isAdvertising) {
            Log.d("BLE", "Advertising sudah berjalan")
            return
        }

        if (!bluetoothAdapter.isEnabled) {
            Log.e("BLE","Bluetooth belum aktif")
            return
        }
        if (advertiser == null) {
            Log.e("BLE", "BLE Advertiser tidak didukung")
            return
        }
        bluetoothAdapter.name = DEVICE_NAME
        isAdvertising = true
        advertiser?.startAdvertising(
            buildSettings(),
            buildAdvertiseData(),
            buildScanResponse(),
            advertiseCallback
        )
        handler.post(advertiseRunnable)
    }

    fun stopAdvertising() {

        if (!isAdvertising) return
        isAdvertising = false
        handler.removeCallbacks(advertiseRunnable)
        advertiser?.stopAdvertising(advertiseCallback)
        Log.d("BLE","Advertising dihentikan")

    }

    private fun generateServiceData(): ByteArray {

        val now = LocalTime.now()
        val timeValue =
            (now.hour * 3600) +
            (now.minute * 60) +
            now.second
        val encrypted = timeValue * 19
        Log.d("BLE", "ServiceData = $encrypted")
        return encrypted
            .toString()
            .toByteArray(Charsets.UTF_8)
    }

    private fun restartAdvertising() {

        advertiser?.stopAdvertising(advertiseCallback)

        advertiser?.startAdvertising(
            buildSettings(),
            buildAdvertiseData(),
            buildScanResponse(),
            advertiseCallback
        )
    }

    private fun buildScanResponse(): AdvertiseData {

        return AdvertiseData.Builder()
            .setIncludeDeviceName(true)
            .addServiceData(
                ParcelUuid(SERVICE_UUID),
                generateServiceData()
            )
            .build()

    }
}