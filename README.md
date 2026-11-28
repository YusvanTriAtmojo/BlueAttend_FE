<p align="center">
  <img src="assets/images/logo.png" alt="Blueattend Logo" width="140" height="140">
</p>

# 📱 BlueAttend - Mobile App

[![Flutter](https://img.shields.io/badge/Flutter-v3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-v3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![State Management](https://img.shields.io/badge/State%20Management-BLoC-40C4FF)](https://bloclibrary.dev)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)](https://developer.android.com)
[![Bluetooth Low Energy](https://img.shields.io/badge/Bluetooth%20Low%20Energy-BLE-0082FC?logo=bluetooth&logoColor=white)](https://pub.dev/packages/flutter_blue_plus)
[![Google ML Kit](https://img.shields.io/badge/Google%20ML%20Kit-0F9D58?logo=google&logoColor=white)](https://pub.dev/packages/google_mlkit_face_detection)
[![Mobile Scanner](https://img.shields.io/badge/Mobile%20Scanner-4285F4?logo=flutter&logoColor=white)](https://pub.dev/packages/mobile_scanner)
[![Pretty QR Code](https://img.shields.io/badge/Pretty%20QR%20Code-000000?logo=qr-code&logoColor=white)](https://pub.dev/packages/pretty_qr_code)


> **BlueAttend Mobile** Aplikasi berbasis Flutter yang memungkinkan pengguna melakukan presensi berdasarkan kedekatan lokasi melalui Bluetooth Low Energy (BLE) dan verifikasi wajah (face recognition). Token presensi dapat dimasukkan secara manual melalui teks maupun diperoleh dengan memindai QR Code. Admin dapat mengatur perangkat Bluetooth yang digunakan sebagai titik presensi serta mengelola event presensi. Aplikasi ini menyediakan antarmuka yang intuitif untuk melakukan presensi dan mengelola sistem presensi melalui integrasi dengan BlueAttend RESTful API Backend.

---

## 🛠️ Tech Stack & Arsitektur

- **Framework:** Flutter (Dart)
- **Architecture:** Clean Architecture (Presentation, Domain, Data)
- **State Management:** BLoC
- **Repository Pattern:** Repository Pattern
- **Networking:** RESTful API (HTTP)
- **Target Platform:** Android
- **Bluetooth:** Bluetooth Low Energy (BLE)
- **Face Detection:** Google ML Kit
- **QR Code:** Pretty QR Code
- **QR Scanner:** Mobile Scanner

---

## ✨ Fitur 

Berikut adalah fitur yang ada pada aplikasi BlueAttend melalui use case diagram:

<p align="center">
  <img src="assets/images/usecase.png" alt="Blueattend UC" width="600">
</p>

## 📱 Hasil Tampilan Aplikasi BlueAttend

Berikut adalah beberapa tampilan hasil dari aplikasi BlueAttend:

<p align="center">
  <img src="assets/images/mobile1.png" alt="BlueAttend IF" width="600">
</p>

<p align="center">
  <img src="assets/images/mobile2.png" alt="BlueAttend IF" width="600">
</p>

<p align="center">
  <img src="assets/images/mobile3.png" alt="BlueAttend IF" width="600">
</p>

---

## 🔗 Backend Repository

Backend source code is available at:

- [BlueAttend Backend](https://github.com/YusvanTriAtmojo/BlueAttend_BE)
