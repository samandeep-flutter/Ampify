import 'package:audio_service/audio_service.dart';

Future<AudioHandler> audioServicesInit() async {
  return await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.samtech.ampify',
        androidNotificationChannelName: 'Ampify',
        androidNotificationOngoing: true),
  );
}

class MyAudioHandler extends BaseAudioHandler {}
