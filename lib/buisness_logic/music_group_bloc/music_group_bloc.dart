import 'dart:async';
import 'dart:io';
import 'package:ampify/buisness_logic/player_bloc/player_bloc.dart';
import 'package:ampify/buisness_logic/player_bloc/player_events.dart';
import 'package:ampify/data/utils/exports.dart';
import 'package:file_picker/file_picker.dart';

class MusicGroupEvent extends Equatable {
  const MusicGroupEvent();

  @override
  List<Object?> get props => [];
}

class MusicGroupInitial extends MusicGroupEvent {
  final String id;
  final LibItemType type;
  const MusicGroupInitial({required this.id, required this.type});

  @override
  List<Object?> get props => [id, type, super.props];
}

class PlaylistInitial extends MusicGroupEvent {
  final String id;
  const PlaylistInitial(this.id);

  @override
  List<Object?> get props => [id, super.props];
}

class PlaylistVisibility extends MusicGroupEvent {
  final bool public;
  const PlaylistVisibility(this.public);

  @override
  List<Object?> get props => [public, super.props];
}

class PlaylistCoverChanged extends MusicGroupEvent {
  final File file;
  const PlaylistCoverChanged(this.file);

  @override
  List<Object?> get props => [file, super.props];
}

class MusicGroupFav extends MusicGroupEvent {
  final String id;
  final bool liked;
  final LibItemType type;
  const MusicGroupFav(this.id, {required this.type, required this.liked});

  @override
  List<Object?> get props => [id, type, liked, super.props];
}

class AlbumInitial extends MusicGroupEvent {
  final String id;
  final LibItemType type;
  const AlbumInitial({required this.id, required this.type});

  @override
  List<Object?> get props => [id, type, super.props];
}

class MusicGroupTitleFade extends MusicGroupEvent {
  final double opacity;
  const MusicGroupTitleFade(this.opacity);

  @override
  List<Object?> get props => [opacity];
}

class MusicGroupState extends Equatable {
  final String? id;
  final double titileOpacity;
  final Thumbnail? thumbnail;
  final Color? bgColor;
  final String? title;
  final List<Track> tracks;
  final LibItemType? type;
  final bool? isFav;
  final bool loading;

  const MusicGroupState({
    required this.id,
    required this.thumbnail,
    required this.bgColor,
    required this.title,
    required this.type,
    required this.titileOpacity,
    required this.isFav,
    required this.tracks,
    required this.loading,
  });

  const MusicGroupState.init()
      : id = null,
        thumbnail = null,
        titileOpacity = 0,
        type = null,
        bgColor = null,
        title = null,
        isFav = false,
        loading = false,
        tracks = const [];

  MusicGroupState copyWith({
    String? id,
    Thumbnail? thumbnail,
    Color? bgColor,
    String? title,
    List<Track>? tracks,
    LibItemType? type,
    bool? isFav,
    bool? loading,
    double? titileOpacity,
  }) {
    return MusicGroupState(
      id: id ?? this.id,
      thumbnail: thumbnail ?? this.thumbnail,
      bgColor: bgColor ?? this.bgColor,
      title: title ?? this.title,
      isFav: isFav,
      // details: details,
      titileOpacity: titileOpacity ?? this.titileOpacity,
      type: type ?? this.type,
      tracks: tracks ?? this.tracks,
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props =>
      [thumbnail, bgColor, title, tracks, type, loading, titileOpacity, isFav];
}

class MusicGroupBloc extends Bloc<MusicGroupEvent, MusicGroupState> {
  MusicGroupBloc() : super(const MusicGroupState.init()) {
    on<MusicGroupInitial>(_onInit);
    on<AlbumInitial>(_onAlbum);
    on<MusicGroupFav>(_onFav);
    on<PlaylistInitial>(_onPlaylist);
    on<MusicGroupTitleFade>(_titleFade);
    on<PlaylistVisibility>(_onVisibility);
    on<PlaylistCoverChanged>(_onCoverChanged);
  }

  final YTMusic _ytMusic = getIt();
  final scrollController = ScrollController();
  bool libRefresh = false;

  String? get uid => BoxServices.instance.uid;

  // @override
  // void add(MusicGroupEvent event) {
  //   debugLog(event, 'event');
  //   super.add(event);
  // }

  void onPlay(BuildContext context) {
    final player = context.read<PlayerBloc>();
    if (player.state.musicGroupId == state.id) return player.onPlayPause();
    player.add(MusicGroupPlayed(id: state.id, tracks: state.tracks));
  }

  Future<bool> pickImage() async {
    try {
      final result = await FilePicker.pickFiles(
          allowMultiple: false, type: FileType.image);
      final file = result?.files.firstOrNull;
      if (file == null) throw FormatException(StringRes.noImage);
      add(PlaylistCoverChanged(File(file.path!)));
      return true;
    } on FormatException catch (e) {
      showToast(e.message);
    } catch (e) {
      logPrint(e, 'image-picker');
    }
    return false;
  }

  void _scrollListener() {
    if (!scrollController.hasClients) return;
    final scroll = Utils.titleScroll(scrollController);
    if (scroll != state.titileOpacity) {
      add(MusicGroupTitleFade(scroll));
    }
  }

  Future<void> _onInit(
      MusicGroupInitial event, Emitter<MusicGroupState> emit) async {
    emit(state.copyWith(id: event.id, loading: true, titileOpacity: 0));
    scrollController.addListener(_scrollListener);
    libRefresh = false;

    if (event.type.isPlaylist) {
      add(PlaylistInitial(event.id));
    } else {
      add(AlbumInitial(id: event.id, type: event.type));
    }
  }

  Future<void> _onPlaylist(
      PlaylistInitial event, Emitter<MusicGroupState> emit) async {
    try {
      final _playlist = Completer<PlaylistFull>();
      _ytMusic.getPlaylist(event.id).then((playlist) {
        _playlist.complete(playlist);
      }, onError: (e) => _playlist.completeError(e));
      final list = await _ytMusic.getPlaylistVideos(event.id);
      final tracks = List<Track>.from(list.map((e) => Track.fromVid(e)));

      final _pl = await _playlist.future;
      final playlist = Playlist.fromYT(_pl);
      final color = await Utils.getImageColor(playlist.thumbnail);
      // TODO: implement fav item check
      // final isFav = await _repo.isFavPlaylist(event.id);
      emit(state.copyWith(
        thumbnail: playlist.thumbnail,
        tracks: tracks,
        type: LibItemType.playlist,
        bgColor: color,
        // isFav: isFav,
        title: playlist.title,
        loading: false,
      ));
    } catch (e) {
      logPrint(e, 'playlist-init');
      emit(state.copyWith(loading: false));
    }
  }

  Future<void> _onAlbum(
      AlbumInitial event, Emitter<MusicGroupState> emit) async {
    try {
      final list = await _ytMusic.getAlbum(event.id);
      final album = Album.fromYtFull(list);

      final color = await Utils.getImageColor(album.thumbnail);
      // TODO: implement fav item check
      //   final isFav = await _repo.isFavAlbum(event.id);
      emit(state.copyWith(
        loading: false,
        bgColor: color,
        title: album.title,
        tracks: album.tracks,
        // isFav: isFav,
        thumbnail: album.thumbnail,
        type: event.type,
      ));
    } catch (e) {
      logPrint(e, 'album-init');
      emit(state.copyWith(loading: false));
    }
  }

  Future<void> _onFav(
      MusicGroupFav event, Emitter<MusicGroupState> emit) async {
    // TODO: implement add to fav songs

    // libRefresh = true;
    // try {
    //   emit(state.copyWith(isFav: !event.liked));
    //   if (event.liked) {
    //     final success = event.type.isPlaylist
    //         ? await _repo.removeSavedPlaylist(event.id)
    //         : await _repo.removeSavedAlbum(event.id);
    //     if (!success) throw const FormatException();
    //   } else {
    //     final success = event.type.isPlaylist
    //         ? await _repo.savePlaylist(event.id)
    //         : await _repo.saveAlbum(event.id);
    //     if (!success) throw const FormatException();
    //   }
    // } on FormatException {
    //   emit(state.copyWith(isFav: event.liked));
    // } catch (e) {
    //   logPrint(e, 'fav');
    // }
  }

  Future<void> _onCoverChanged(
      PlaylistCoverChanged event, Emitter<MusicGroupState> emit) async {
    // TODO: implement change cover image

    // showToast(StringRes.uploading);
    // emit(state.copyWith(image: ''));
    // final image = await event.file.readAsBytes();
    // await _repo.changeCoverImage(id: state.id!, image: base64Encode(image));
    // add(PlaylistInitial(state.id!));
  }

  Future<void> _onVisibility(
      PlaylistVisibility event, Emitter<MusicGroupState> emit) async {
    // TODO: implement change visibility

    // await _repo.editPlaylist(
    //   id: state.id!,
    //   title: state.title!,
    //   desc: state.details?.description ?? '',
    //   public: event.public,
    // );
    // add(PlaylistInitial(state.id!));
    // if (event.public) {
    //   showToast(StringRes.nowPublic);
    //   return;
    // }
    // showToast(StringRes.nowPrivate);
  }

  void _titleFade(MusicGroupTitleFade event, Emitter<MusicGroupState> emit) {
    emit(state.copyWith(titileOpacity: event.opacity));
  }
}
