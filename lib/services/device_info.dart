import 'dart:io';
import 'package:ampify/data/utils/exports.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceInfoService {
  static final _device = DeviceInfoPlugin();

  static Future<DeviceInfoModel> getInfo({String? fcmToken}) async {
    final package = await PackageInfo.fromPlatform();
    final info = {};

    if (kIsWeb) {
      final _info = await _device.webBrowserInfo;
      info.addAll({
        'deviceId': _info.userAgent,
        'deviceName': _info.browserName.name,
        'deviceModel': _info.platform ?? 'Unknown',
        'osVersion': _info.userAgent ?? 'Unknown',
        'manufacturer': 'Web Browser',
      });
    } else {
      switch (Platform.operatingSystem) {
        case 'android':
          final _info = await _device.androidInfo;
          info.addAll({
            'deviceId': _info.id,
            'deviceName': _info.device,
            'deviceModel': _info.model,
            'osVersion': 'Android ${_info.version.release}',
            'manufacturer': _info.manufacturer,
          });
          break;
        case 'ios':
          final _info = await _device.iosInfo;
          info.addAll({
            'deviceId': _info.identifierForVendor,
            'deviceName': _info.name,
            'deviceModel': _info.model,
            'osVersion': 'iOS ${_info.systemVersion}',
            'manufacturer': 'Apple',
          });
          break;
        case 'macos':
          final _info = await _device.macOsInfo;
          info.addAll({
            'deviceId': _info.systemGUID,
            'deviceName': _info.computerName,
            'deviceModel': _info.model,
            'osVersion': 'macOS ${_info.osRelease}',
            'manufacturer': 'Apple',
          });
          break;
        case 'windows':
          final _info = await _device.windowsInfo;
          info.addAll({
            'deviceId': _info.deviceId.replaceAll(RegExp(r'[{}]'), ''),
            'deviceName': _info.computerName,
            'deviceModel': _info.productName,
            'osVersion': 'Windows ${_info.majorVersion}.${_info.minorVersion}',
            'manufacturer': 'Microsoft',
          });
          break;
        case 'linux':
          final _info = await _device.linuxInfo;
          info.addAll({
            'deviceId': _info.id,
            'deviceName': _info.name,
            'deviceModel': _info.prettyName,
            'osVersion': _info.version ?? 'Unknown',
            'manufacturer': 'Linux',
          });
          break;
      }
    }
    dprint(info, name: 'device-info');
    return DeviceInfoModel.fromJson({
      ...info,
      'appType': _type,
      'deviceType': _os,
      'fcmToken': fcmToken,
      'appVersion': package.version,
      'lastUpdated': DateTime.now().toIso8601String(),
      'packageName': package.packageName,
      'buildNumber': package.buildNumber,
    });
  }

  static String get _type {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid || Platform.isIOS) {
      return 'mobile';
    }
    return 'desktop';
  }

  static String get _os {
    if (kIsWeb) return 'web';
    return Platform.operatingSystem;
  }

  static Future<DeviceInfoModel> updateFCM(String? token) async {
    try {
      final box = BoxServices.instance;
      final json = box.read(BoxKeys.deviceInfo);
      final info = DeviceInfoModel.fromJson(json);
      return info.copyWith(token);
    } catch (e) {
      return await getInfo(fcmToken: token);
    }
  }

  static void show(BuildContext context) {
    final AuthServices auth = getIt();

    showDialog(
      context: context,
      builder: (context) {
        return MyAlertDialog(
          title: Row(
            children: [
              Text(StringRes.deviceInfo),
              const SizedBox(width: Dimens.sizeSmall),
              IconButton(
                onPressed: () {
                  final _info = auth.deviceInfo?.toJson().toString();
                  if (_info?.isEmpty ?? true) return;
                  Clipboard.setData(ClipboardData(text: _info!));
                  showToast(StringRes.copiedToClipboard);
                },
                iconSize: Dimens.sizeMedium,
                icon: Icon(Icons.copy),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(StringRes.close),
              ),
            ],
          ),
          titleTextStyle: Utils.defTitleStyle(context.scheme.textColor),
          insetPadding: EdgeInsets.all(Dimens.sizeDefault),
          content: Column(
            spacing: Dimens.sizeExtraSmall,
            mainAxisSize: MainAxisSize.min,
            children: [
              InfoWidget('Device ID', content: auth.deviceInfo?.deviceId),
              InfoWidget('Package', content: auth.deviceInfo?.packageName),
              InfoWidget(
                'App Version',
                content:
                    '${auth.deviceInfo?.appVersion}+${auth.deviceInfo?.buildNumber}',
              ),
              InfoWidget(
                'Device Model',
                content:
                    '${auth.deviceInfo?.deviceModel} (${auth.deviceInfo?.manufacturer})',
              ),
              InfoWidget('Device Name', content: auth.deviceInfo?.deviceName),
              InfoWidget('OS Version', content: auth.deviceInfo?.osVersion),
              InfoWidget(
                'Last Updated',
                content: auth.deviceInfo?.lastUpdated?.formatDateSt,
              ),
            ],
          ),
        );
      },
    );
  }
}
