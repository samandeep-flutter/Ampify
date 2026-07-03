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
      deviceId: json['device_id'],
      deviceType: json['device_type'],
      fcmToken: json['fcm_token'],
      appVersion: json['app_version'],
      appType: json['app_type'],
      deviceModel: json['device_model'],
      deviceName: json['device_name'],
      osVersion: json['os_version'],
      manufacturer: json['manufacturer'],
      lastUpdated: DateTime.tryParse(json['last_updated'] ?? ''),
      packageName: json['package_name'],
      buildNumber: json['build_number'],
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
        'device_id': deviceId,
        'device_type': deviceType,
        'fcm_token': fcmToken,
        'app_version': appVersion,
        'app_type': appType,
        'device_model': deviceModel,
        'device_name': deviceName,
        'os_version': osVersion,
        'manufacturer': manufacturer,
        'last_updated': lastUpdated?.toIso8601String(),
        'package_name': packageName,
        'build_number': buildNumber,
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
