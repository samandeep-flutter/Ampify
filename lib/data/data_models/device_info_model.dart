import 'package:equatable/equatable.dart';

class DeviceInfoModel extends Equatable {
  final String? deviceId;
  final String? deviceType;
  final String? fcmToken;
  final String? appVersion;
  final String? appType;
  final String? deviceModel;
  final String? deviceName;
  final String? osVersion;
  final String? manufacturer;
  final DateTime? lastUpdated;
  final String? packageName;
  final String? buildNumber;

  const DeviceInfoModel({
    required this.deviceId,
    required this.deviceType,
    required this.fcmToken,
    required this.appVersion,
    required this.appType,
    required this.deviceModel,
    required this.deviceName,
    required this.osVersion,
    required this.manufacturer,
    required this.lastUpdated,
    required this.packageName,
    required this.buildNumber,
  });

  factory DeviceInfoModel.fromJson(Map<String, dynamic> json) {
    return DeviceInfoModel(
      deviceId: json['deviceId'],
      deviceType: json['deviceType'],
      fcmToken: json['fcmToken'],
      appVersion: json['appVersion'],
      appType: json['appType'],
      deviceModel: json['deviceModel'],
      deviceName: json['deviceName'],
      osVersion: json['osVersion'],
      manufacturer: json['manufacturer'],
      lastUpdated: DateTime.tryParse(json['lastUpdated'] ?? ''),
      packageName: json['packageName'],
      buildNumber: json['buildNumber'],
    );
  }

  DeviceInfoModel copyWith(String? fcmToken) {
    return DeviceInfoModel(
      deviceId: deviceId,
      deviceType: deviceType,
      fcmToken: fcmToken ?? this.fcmToken,
      appVersion: appVersion,
      appType: appType,
      deviceModel: deviceModel,
      deviceName: deviceName,
      osVersion: osVersion,
      manufacturer: manufacturer,
      lastUpdated: DateTime.now(),
      packageName: packageName,
      buildNumber: buildNumber,
    );
  }

  Map<String, dynamic> toJson() => {
        'deviceId': deviceId,
        'deviceType': deviceType,
        'fcmToken': fcmToken,
        'appVersion': appVersion,
        'appType': appType,
        'deviceModel': deviceModel,
        'deviceName': deviceName,
        'osVersion': osVersion,
        'manufacturer': manufacturer,
        'lastUpdated': lastUpdated?.toIso8601String(),
        'packageName': packageName,
        'buildNumber': buildNumber,
      };
  Map<String, dynamic> deviceInfoJson() => {
        'deviceType': deviceType,
        'deviceModel': deviceModel,
        'deviceName': deviceName,
        'manufacturer': manufacturer,
        'appVersion': appVersion,
        'buildNumber': buildNumber,
      };

  @override
  List<Object?> get props => [
        deviceId,
        deviceType,
        fcmToken,
        appVersion,
        appType,
        deviceModel,
        deviceName,
        osVersion,
        manufacturer,
        lastUpdated,
        packageName,
        buildNumber,
      ];
}
