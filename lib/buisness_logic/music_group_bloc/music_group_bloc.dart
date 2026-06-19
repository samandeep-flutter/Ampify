import 'dart:async';
import 'package:ampify/data/utils/exports.dart';

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

// class PlaylistVisibility extends MusicGroupEvent {
//   final bool public;
//   const PlaylistVisibility(this.public);

//   @override
//   List<Object?> get props => [public, super.props];
// }

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
  final Color? bgColor;
  final String? owner;
  final LibraryModel? item;
  final String? subtitle;
  final String? description;
  final List<Track> tracks;
  final bool? isFav;
  final bool loading;

  const MusicGroupState({
    required this.id,
    required this.bgColor,
    required this.item,
    required this.subtitle,
    required this.owner,
    required this.description,
    required this.titileOpacity,
    required this.isFav,
    required this.tracks,
    required this.loading,
  });

  const MusicGroupState.init()
      : id = null,
        titileOpacity = 0,
        bgColor = null,
        item = null,
        subtitle = null,
        owner = null,
        description = null,
        isFav = false,
        loading = false,
        tracks = const [];

  MusicGroupState copyWith({
    String? id,
    Color? bgColor,
    String? owner,
    LibraryModel? item,
    String? subtitle,
    String? description,
    double? titileOpacity,
    List<Track>? tracks,
    bool? isFav,
    bool? loading,
  }) {
    return MusicGroupState(
      id: id ?? this.id,
      bgColor: bgColor ?? this.bgColor,
      item: item ?? this.item,
      subtitle: subtitle ?? this.subtitle,
      owner: owner ?? this.owner,
      isFav: isFav,
      description: description ?? this.description,
      titileOpacity: titileOpacity ?? this.titileOpacity,
      tracks: tracks ?? this.tracks,
      loading: loading ?? this.loading,
    );
  }

  LibItemType? get type => item?.type;
  String? get cover => item?.thumbnail?.url;

  @override
  List<Object?> get props => [
        bgColor,
        item,
        subtitle,
        owner,
        description,
        tracks,
        loading,
        titileOpacity,
        isFav
      ];
}

class MusicGroupBloc extends Bloc<MusicGroupEvent, MusicGroupState> {
  MusicGroupBloc() : super(const MusicGroupState.init()) {
    on<MusicGroupInitial>(_onInit);
    on<AlbumInitial>(_onAlbum);
    on<MusicGroupFav>(_onFav);
    on<PlaylistInitial>(_onPlaylist);
    on<MusicGroupTitleFade>(_titleFade);
    // on<PlaylistVisibility>(_onVisibility);
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
        item: LibraryModel(
          id: playlist.id,
          title: playlist.title,
          thumbnail: playlist.thumbnail,
          type: LibItemType.playlist,
        ),
        tracks: tracks,
        bgColor: color,
        subtitle: '${playlist.videoCount} views',
        // isFav: isFav,
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
        item: LibraryModel(
          id: album.id,
          title: album.title,
          thumbnail: album.thumbnail,
          type: LibItemType.album,
          artist: album.artist,
        ),
        tracks: album.tracks,
        subtitle: album.year?.toString(),
        // isFav: isFav,
      ));
    } catch (e) {
      logPrint(e, 'album-init');
      emit(state.copyWith(loading: false));
    }
  }

  Future<void> _onFav(
      MusicGroupFav event, Emitter<MusicGroupState> emit) async {
    libRefresh = true;
    try {
      emit(state.copyWith(isFav: !event.liked));
      // TODO: implement fav item
      // if (event.liked) {
      //   _repo.doc(event.id).delete();
      // } else {
      //   _repo.doc(event.id).set(data);
      // }
    } catch (e) {
      logPrint(e, 'fav');
    }
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

  void _titleFade(MusicGroupTitleFade event, Emitter<MusicGroupState> emit) {
    emit(state.copyWith(titileOpacity: event.opacity));
  }
}
