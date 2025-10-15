import 'package:ampify/buisness_logic/player_bloc/player_state.dart';
import 'package:ampify/data/data_models/common/tracks_model.dart';
import 'package:ampify/services/theme_services.dart';
import 'package:ampify/data/data_models/common/artist_model.dart';
import 'package:ampify/data/data_models/library_model.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

extension MyContext on BuildContext {
  Color get background => ThemeServices.of(this).background;
  double get height => MediaQuery.sizeOf(this).height;
  double get width => MediaQuery.sizeOf(this).width;
  Orientation get orientation => MediaQuery.orientationOf(this);
  double get bottomInsets => MediaQuery.viewInsetsOf(this).bottom;
  bool get isDarkMode =>
      MediaQuery.platformBrightnessOf(this) == Brightness.dark;

  void close(int count) {
    int popped = 0;
    Navigator.of(this).popUntil((route) => popped++ >= count);
  }
}

extension MyIterable on Iterable<String> {
  String get asString {
    return toString().replaceAll(RegExp(r'[\[\]]'), '');
  }
}

extension ListToString on List<String> {
  String get asString => toString().replaceAll(RegExp(r'[\[\]]'), '');
}

extension ArtistNames on List<Artist> {
  String get asString => List<String>.from(map((e) => e.name)).asString;
}

extension MyMusicState on MusicState? {
  bool get isHidden => this == MusicState.hidden;
  bool get isPlaying => this == MusicState.playing;
  bool get isLoading => this == MusicState.loading;
}

extension MyLibItem on LibItemType? {
  bool get isPlaylist => this == LibItemType.playlist;
  bool get isTrack => this == LibItemType.track;
  // bool get isAlbum =>
  //     this == LibItemType.album ||
  //     this == LibItemType.compilation ||
  //     this == LibItemType.single;
}

extension MyMediaItems on MediaItem {
  AudioSource get toAudioSource {
    return AudioSource.uri(Uri.parse(extras!['uri'] as String), tag: extras);
  }
}

extension MyQueue on ValueStream<List<MediaItem>> {
  bool isLast(List<TrackDetails> queue) {
    if (value.isEmpty || queue.isEmpty) return false;
    return queue.first.id == value.last.id;
  }
}

extension MyList<T> on List<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (T element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  T? get firstElement => isEmpty ? null : first;
}

extension MyPlaybackState on PlaybackState {
  /// Helper method to get the adjacent [MusicState] from [AudioProcessingState].
  ///
  /// [MusicState] is a music player's status.
  MusicState get playerState {
    switch (processingState) {
      case AudioProcessingState.loading:
        return MusicState.loading;

      case AudioProcessingState.buffering:
        return MusicState.playing;

      case AudioProcessingState.ready:
        return playing ? MusicState.playing : MusicState.pause;

      case AudioProcessingState.completed:
      case AudioProcessingState.error:
      case AudioProcessingState.idle:
        return MusicState.hidden;
    }
  }
}

extension MyRepeatMode on LoopMode {
  /// Helper method to get the adjacent [AudioServiceRepeatMode] from [LoopMode].
  ///
  /// [AudioServiceRepeatMode] is from [audio_service].
  AudioServiceRepeatMode get toRepeatMode {
    switch (this) {
      case LoopMode.off:
        return AudioServiceRepeatMode.none;
      case LoopMode.all:
        return AudioServiceRepeatMode.all;
      case LoopMode.one:
        return AudioServiceRepeatMode.one;
    }
  }
}

extension MyLoopMode on AudioServiceRepeatMode {
  /// Helper method to get the adjacent [LoopMode] from [AudioServiceRepeatMode].
  ///
  /// [LoopMode] is from [just_audio].
  /// [AudioServiceRepeatMode] is from [audio_service].
  MusicLoopMode? get toLoopMode {
    switch (this) {
      case AudioServiceRepeatMode.none:
        return MusicLoopMode.off;
      case AudioServiceRepeatMode.all:
        return MusicLoopMode.all;
      case AudioServiceRepeatMode.one:
        return MusicLoopMode.once;

      default:
        return null;
    }
  }
}

extension ExtendedMusicLoopMode on MusicLoopMode {
  bool get isOff => this == MusicLoopMode.off;

  /// Helper method to get the adjacent [AudioServiceRepeatMode] from [MusicLoopMode].
  ///
  /// [MusicLoopMode] is music player's loop mode.
  AudioServiceRepeatMode get toAudioState {
    switch (this) {
      case MusicLoopMode.off:
        return AudioServiceRepeatMode.none;
      case MusicLoopMode.all:
        return AudioServiceRepeatMode.all;
      case MusicLoopMode.once:
        return AudioServiceRepeatMode.one;
    }
  }
}

extension MyAudioProcessingState on ProcessingState {
  AudioProcessingState get toAudioState {
    switch (this) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }
}

extension MusicDuration on Duration? {
  bool get isZero => (this?.inSeconds ?? 0) == 0;
  String format() => _format(this);

  double widthFactor(Duration? total) {
    if ((total?.inSeconds ?? 0) == 0) return 0;
    return (this?.inSeconds ?? 0) / total!.inSeconds;
  }

  String _format(Duration? time) {
    if (time == null) return '0:00';
    if (time.inMinutes >= 60) {
      final min = time.inMinutes - (time.inHours * 60);
      return '${time.inHours}:${min.digit2}';
    }
    if (time.inSeconds >= 60) {
      final sec = time.inSeconds - (time.inMinutes * 60);
      return '${time.inMinutes}:${sec.digit2}';
    }
    return '0:${time.inSeconds.digit2}';
  }
}

extension MyDuration on Duration {
  Duration ceil() {
    final _seconds = (inMilliseconds / 1000).ceil();
    return Duration(seconds: _seconds);
  }
}

extension MyDateTime on DateTime {
  String toJson() => _dateTime(this);
  String get formatDate => '${_months[month - 1]} ${day.digit2}, $year';
  String get formatTime => '${hour.digit2}:${minute.digit2}';
  String get formatLongTime =>
      '${hour.digit2}:${minute.digit2}:${second.digit2}';

  String _dateTime(DateTime now) {
    String date = '${now.year}${now.month.digit2}${now.day.digit2}';
    String time = '${now.hour.digit2}${now.minute.digit2}'
        '${now.second.digit2}${now.millisecond.digit3}';
    return date + time;
  }

  List<String> get _months => [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
}

extension MyString on String {
  DateTime get toDateTime => _formJson(this);
  bool get isEmail => _emailRegExp(this);
  bool get isStringPass => _passRegExp(this);
  int queryMatch(String query) => _calculateMatch(this, query);

  String get removeCoprights =>
      replaceAll(RegExp(r'(?<!\w)[CcPp](?!\w)|\([CcPp]\)'), '');
  String get capitalize => '${this[0].toUpperCase()}${substring(1)}';
  String get unescape => HtmlUnescape().convert(this);
  String get noSpace => replaceAll(' ', '');

  DateTime _formJson(String datetime) {
    int year = int.parse(datetime.substring(0, 4));
    int month = int.parse(datetime.substring(4, 6));
    int day = int.parse(datetime.substring(6, 8));
    int hour = int.parse(datetime.substring(8, 10));
    int min = int.parse(datetime.substring(10, 12));
    int sec = int.parse(datetime.substring(12, 14));
    int milli = int.parse(datetime.substring(14, 17));
    return DateTime(year, month, day, hour, min, sec, milli);
  }

  bool _emailRegExp(String text) {
    final emailExp =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailExp.hasMatch(text);
  }

  bool _passRegExp(String text) {
    final passExp = RegExp(r'^(?=.*[A-Z])(?=.*\d).{6,}$');
    return passExp.hasMatch(text);
  }

  int _calculateMatch(String item, String searchText) {
    item = item.toLowerCase();
    searchText = searchText.toLowerCase();
    if (item == searchText) {
      return 3;
    } else if (item.startsWith(searchText)) {
      return 2;
    } else if (item.contains(searchText)) {
      return 1;
    }
    return 0;
  }
}

extension MyBrightness on ThemeMode {
  Brightness get brightness {
    switch (this) {
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness;
    }
  }

  IconData get icon {
    switch (this) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.contrast;
    }
  }
}

extension SortMusicGroup on List<LibraryModel> {
  void sortLibrary(String query) => sort((a, b) {
        final fName = a.name?.queryMatch(query) ?? 0;
        final fArtist = a.owner?.name?.queryMatch(query) ?? 0;
        final first = fName.compareTo(fArtist);

        final sName = b.name?.queryMatch(query) ?? 0;
        final sArtist = b.owner?.name?.queryMatch(query) ?? 0;
        final second = sName.compareTo(sArtist);

        return second.compareTo(first);
      });
}

extension MyInt on int {
  String get format => _format(this);
  String get digit2 => this < 10 ? '0${toString()}' : toString();
  String get digit3 => _digit3(this);

  String _digit3(int count) {
    switch (count) {
      case < 10:
        return '00${toString()}';
      case < 100:
        return '0${toString()}';
      default:
        return toString();
    }
  }

  String _format(int count) {
    if (count > 999999) {
      String newCount = (count / 1000000).toStringAsFixed(1);
      bool isZero = newCount.split('.').last == '0';
      return '${isZero ? newCount.split('.').first : newCount}M';
    }
    if (count > 999) {
      String newCount = (count / 1000).toStringAsFixed(1);
      bool isZero = newCount.split('.').last == '0';
      return '${isZero ? newCount.split('.').first : newCount}K';
    }
    return count.toString();
  }
}
