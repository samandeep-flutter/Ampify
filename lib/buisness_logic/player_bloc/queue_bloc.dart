import 'package:ampify/buisness_logic/player_bloc/player_state.dart';
import 'package:ampify/data/data_models/common/tracks_model.dart';
import 'package:ampify/data/utils/app_constants.dart';
import 'package:ampify/data/utils/string.dart';
import 'package:ampify/data/utils/utils.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/transformers.dart';

class QueueEvents extends Equatable {
  const QueueEvents();

  @override
  List<Object?> get props => [];
}

class QueueInitial extends QueueEvents {}

class QueueItemSelected extends QueueEvents {
  final int index;
  const QueueItemSelected(this.index);

  @override
  List<Object?> get props => [super.props, index];
}

class QueueTrackAdded extends QueueEvents {
  final Track track;
  const QueueTrackAdded(this.track);

  @override
  List<Object?> get props => [super.props, track];
}

class QueueState extends Equatable {
  final List<TrackDetails> queue;
  final List<bool> selected;
  const QueueState({required this.queue, required this.selected});

  const QueueState.init()
      : queue = const [],
        selected = const [];

  QueueState copyWith({
    List<TrackDetails>? queue,
    List<bool>? selected,
  }) {
    return QueueState(
      queue: queue ?? this.queue,
      selected: selected ?? this.selected,
    );
  }

  @override
  List<Object?> get props => [queue, selected];
}

EventTransformer<T> _debounce<T>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
}

class QueueBloc extends Bloc<QueueEvents, QueueState> {
  QueueBloc() : super(const QueueState.init()) {
    on<QueueInitial>(_onInit);
    on<QueueItemSelected>(_onItemSelected);
    on<QueueTrackAdded>(_onTrackAdded, transformer: _debounce(duration));
  }

  final duration = const Duration(milliseconds: 500);

  _onInit(QueueInitial event, Emitter<QueueState> emit) {}

  _onItemSelected(QueueItemSelected event, Emitter<QueueState> emit) {
    List<bool> selected = state.selected;
    selected[event.index] = !selected[event.index];
    emit(state.copyWith(selected: selected));
  }

  onSelected(int index) => add(QueueItemSelected(index));

  _onTrackAdded(QueueTrackAdded event, Emitter<QueueState> emit) async {
    showToast(StringRes.queueAdded);
    final track = await Utils.getTrackDetails(event.track);
    final selected = List.generate(state.queue.length + 1, (_) => false);
    emit(state.copyWith(queue: [...state.queue, track], selected: selected));
  }
}
