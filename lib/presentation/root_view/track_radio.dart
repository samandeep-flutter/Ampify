import 'dart:async';
import 'dart:math';

import 'package:ampify/buisness_logic/player_bloc/player_bloc.dart';
import 'package:ampify/buisness_logic/player_bloc/player_events.dart';
import 'package:ampify/buisness_logic/player_bloc/player_state.dart';
import 'package:ampify/buisness_logic/player_bloc/track_radio_bloc.dart';
import 'package:ampify/presentation/track_widgets/track_tile.dart';
import 'package:ampify/data/utils/exports.dart';
import 'package:flutter/cupertino.dart';

class TrackRadio extends StatefulWidget {
  final String id;
  final Object? track;
  const TrackRadio(this.id, {super.key, required this.track});

  @override
  State<TrackRadio> createState() => _TrackRadioState();
}

class _TrackRadioState extends State<TrackRadio> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<TrackRadioBloc>();
    try {
      final json = widget.track as Map<String, dynamic>;
      final track = Track.fromJson(json);
      bloc.add(TrackRadioInitial(widget.id, track: track));
    } catch (e) {
      bloc.add(TrackRadioInitial(widget.id, track: null));
      logPrint(e, 'radio-parse');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TrackRadioBloc>();
    final scheme = context.scheme;
    final fgColor = scheme.backgroundDark;

    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: scheme.background,
        body: CustomScrollView(
          controller: bloc.scrollController,
          physics: const BottomBounceScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              centerTitle: false,
              title: BlocBuilder<TrackRadioBloc, TrackRadioState>(
                buildWhen: (pr, cr) {
                  final opacity = pr.titileOpacity != cr.titileOpacity;
                  return opacity || pr.title != cr.title;
                },
                builder: (context, state) {
                  return AnimatedOpacity(
                      opacity: state.titileOpacity,
                      duration: Durations.long2,
                      child: Text('${state.title ?? ''}\'s Radio'));
                },
              ),
              backgroundColor: Color.alphaBlend(fgColor, scheme.background),
              titleTextStyle: Utils.defTitleStyle(context),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: Utils.insetsHoriz(Dimens.sizeDefault),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.alphaBlend(fgColor, scheme.background),
                      scheme.background,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: Dimens.sizeSmall),
                    BlocBuilder<TrackRadioBloc, TrackRadioState>(
                        buildWhen: (pr, cr) => pr.title != cr.title,
                        builder: (context, state) {
                          return Text('${state.title ?? ''}\'s Radio',
                              style: Utils.titleStyleLarge(context));
                        }),
                    const SizedBox(height: Dimens.sizeExtraSmall),
                    Text(
                      'Desc',
                      style: TextStyle(
                        color: scheme.textColorLight,
                        fontSize: Dimens.fontDefault - 1,
                      ),
                    ),
                    const SizedBox(height: Dimens.sizeDefault),
                    Wrap(
                      runSpacing: Dimens.sizeSmall,
                      spacing: Dimens.sizeSmall,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Radio',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: Dimens.fontDefault,
                                color: scheme.textColor,
                              ),
                            ),
                            PaginationDots(
                              current: true,
                              margin: Dimens.sizeSmall,
                              color: scheme.textColor,
                            ),
                            Icon(
                              Icons.track_changes,
                              color: scheme.textColorLight,
                              size: Dimens.iconMedSmall,
                            ),
                            const SizedBox(width: Dimens.sizeExtraSmall),
                            BlocBuilder<TrackRadioBloc, TrackRadioState>(
                                buildWhen: (pr, cr) => pr.loading != cr.loading,
                                builder: (context, state) {
                                  if (state.loading) return const Text('');
                                  return Text(
                                    '${state.tracks.length} tracks',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: scheme.textColorLight,
                                      fontSize: Dimens.fontDefault,
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimens.sizeDefault),
                    BlocBuilder<TrackRadioBloc, TrackRadioState>(
                        buildWhen: (pr, cr) => pr.loading != cr.loading,
                        builder: (context, state) {
                          return Row(
                            children: [
                              DisabledWidget(
                                disabled: state.loading,
                                child: ElevatedButton.icon(
                                    onPressed: _appendTracks,
                                    style: ElevatedButton.styleFrom(
                                        visualDensity: VisualDensity.compact,
                                        backgroundColor: scheme.textColor,
                                        foregroundColor: scheme.background),
                                    iconAlignment: IconAlignment.end,
                                    label: Text(StringRes.appendTracks),
                                    icon: Icon(Icons.library_music_outlined)),
                              ),
                              const Spacer(),
                              DisabledWidget(
                                disabled: state.loading || true,
                                child: BlocBuilder<PlayerBloc, PlayerState>(
                                    buildWhen: (pr, cr) =>
                                        pr.shuffle != cr.shuffle,
                                    builder: (context, state) {
                                      return IconButton(
                                        onPressed: _shuffleToggle,
                                        iconSize: Dimens.iconDefault,
                                        isSelected: state.shuffle,
                                        style: IconButton.styleFrom(
                                            backgroundColor: state.shuffle
                                                ? scheme.primary
                                                : null),
                                        selectedIcon: Image.asset(
                                            ImageRes.shuffle,
                                            width: Dimens.iconMedium,
                                            color: scheme.onPrimary),
                                        icon: Image.asset(ImageRes.shuffle,
                                            height: Dimens.iconMedium,
                                            color: scheme.textColor),
                                      );
                                    }),
                              ),
                              const SizedBox(width: Dimens.sizeDefault),
                              DisabledWidget(
                                disabled: state.loading,
                                child: BlocBuilder<PlayerBloc, PlayerState>(
                                    buildWhen: (pr, cr) {
                                  return pr.playerState != cr.playerState;
                                }, builder: (context, pl) {
                                  final group = pl.musicGroupId == state.id;
                                  return IconButton(
                                    onPressed: () => bloc.onPlay(context),
                                    iconSize: Dimens.iconXLarge,
                                    isSelected:
                                        group && pl.playerState.isPlaying,
                                    selectedIcon: const Icon(Icons.pause),
                                    style: IconButton.styleFrom(
                                      backgroundColor: scheme.textColor,
                                      foregroundColor: scheme.surface,
                                      splashFactory: NoSplash.splashFactory,
                                    ),
                                    icon: const Icon(Icons.play_arrow),
                                  );
                                }),
                              ),
                            ],
                          );
                        }),
                  ],
                ),
              ),
            ),
            BlocBuilder<TrackRadioBloc, TrackRadioState>(
                buildWhen: (pr, cr) => pr.loading != cr.loading,
                builder: (context, state) {
                  if (state.loading) return const _LoadingWidget();

                  return SliverList.builder(
                      itemCount: state.tracks.length,
                      itemBuilder: (_, index) =>
                          TrackTile(state.tracks[index]));
                }),
            const SliverSizedBox(height: Dimens.sizeLarge),
            BlocBuilder<TrackRadioBloc, TrackRadioState>(
                buildWhen: (pr, cr) => pr.loading != cr.loading,
                builder: (context, state) {
                  if (state.loading) return SliverSizedBox();
                  return SliverToBoxAdapter(
                    child: DefaultTextStyle.merge(
                      style: TextStyle(
                          color: scheme.textColorLight,
                          fontSize: Dimens.fontDefault + 1),
                      child: Row(
                        children: [
                          const SizedBox(width: Dimens.sizeDefault),
                          Icon(
                            Icons.track_changes,
                            color: scheme.textColorLight,
                            size: Dimens.iconMedSmall,
                          ),
                          const SizedBox(width: Dimens.sizeSmall),
                          Text('${state.tracks.length} Tracks'),
                          PaginationDots(
                            current: true,
                            margin: Dimens.sizeSmall,
                            color: scheme.textColorLight,
                          ),
                          Text('Radio Tracks'),
                        ],
                      ),
                    ),
                  );
                }),
            SliverSizedBox(height: context.height * .2),
          ],
        ));
  }

  void _shuffleToggle() {
    final player = context.read<PlayerBloc>();
    player.add(PlayerShuffleToggle());
  }

  void _appendTracks() {
    final player = context.read<PlayerBloc>();
    final bloc = context.read<TrackRadioBloc>();
    player.add(PlayerAppendTracks(bloc.state.tracks, id: bloc.state.id));
  }
}

class _LoadingWidget extends StatefulWidget {
  // ignore: unused_element_parameter
  const _LoadingWidget({super.key});

  @override
  State<_LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<_LoadingWidget> {
  final loaders = StringRes.radioLoaders;
  final random = Random();

  late int index;
  late DateTime elapsed;
  int progress = 1;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    elapsed = DateTime.now();
    index = random.nextInt(loaders.length);
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      progress = switch (progress) {
        9 => progress = 1,
        4 => progress + 2,
        _ => progress + 1,
      };
      final now = DateTime.now();
      if (now.difference(elapsed).inSeconds > 3) {
        index = random.nextInt(loaders.length);
        elapsed = now;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return SliverToBoxAdapter(
      child: Container(
        margin: Utils.insetsOnly(Dimens.sizeDefault, top: context.height * .1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                CupertinoActivityIndicator.partiallyRevealed(
                    progress: progress / 10, radius: Dimens.sizeLarge),
                Opacity(
                  opacity: .3,
                  child: CupertinoActivityIndicator.partiallyRevealed(
                      progress: .9, radius: Dimens.sizeLarge),
                ),
              ],
            ),
            const SizedBox(height: Dimens.sizeLarge),
            Builder(builder: (context) {
              final now = DateTime.now();
              final diff = now.difference(elapsed).inSeconds;
              return Text(
                loaders[index] + _builder(diff),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: scheme.textColorLight, fontSize: Dimens.fontDefault),
              );
            })
          ],
        ),
      ),
    );
  }

  String _builder(int diff) {
    return switch (diff) {
      1 => '   ',
      2 => '.  ',
      3 => '.. ',
      _ => '...',
    };
  }
}
