import 'package:ampify/data/utils/exports.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';

typedef Dfunc = void Function(dynamic);

class BoxServices {
  static BoxServices? _instance;
  static BoxServices get instance => _instance ??= BoxServices._init();
  BoxServices._init();

  final db = GetStorage(BoxKeys.boxName);

  static Future<void> initialize() async {
    final support = await getApplicationSupportDirectory();
    await GetStorage(BoxKeys.boxName, support.path).initStorage;
  }

  MyTheme get theme {
    return MyTheme.values.firstWhere(
      (e) => e.title == read(BoxKeys.theme),
      orElse: () => MyTheme.values.first,
    );
  }

  String? get uid => read<String>(BoxKeys.uid);
  String? get token => read<String>(BoxKeys.token);

  Future<void> saveTheme(MyTheme theme) async {
    await write(BoxKeys.theme, theme.title);
  }

  ThemeMode get themeMode {
    return ThemeMode.values.firstWhere(
      (e) => e.name == read(BoxKeys.themeMode),
      orElse: () => ThemeMode.dark,
    );
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    await write(BoxKeys.themeMode, mode.name);
  }

  Future<void> removeAll(List<String> keys) async {
    for (var key in keys) {
      await remove(key);
    }
  }

  Future<void> write(String key, dynamic value) async =>
      await db.write(key, value);

  void listen(String key, Dfunc listener) => db.listenKey(key, listener);

  T? read<T>(String key) => db.read<T>(key);

  bool exist(String key) => db.hasData(key);

  Iterable<String> get keys => db.getKeys();

  Future<void> remove(String key) async => await db.remove(key);

  Future<void> clear() async => await db.erase();
}
