import 'package:ampify/buisness_logic/player_bloc/player_state.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QueueEvents extends Equatable {
  const QueueEvents();

  @override
  List<Object?> get props => [];
}

class QueueInitial extends QueueEvents {}

class QueueTrackAdded extends QueueEvents {
  final TrackDetails track;
  const QueueTrackAdded(this.track);

  @override
  List<Object?> get props => [track];
}

class QueueState extends Equatable {
  final List<TrackDetails> queue;
  const QueueState(this.queue);

  const QueueState.init() : queue = const [];

  @override
  List<Object?> get props => [queue];
}

class QueueBloc extends Bloc<QueueEvents, QueueState> {
  QueueBloc() : super(const QueueState.init()) {
    on<QueueInitial>(_onInit);
    on<QueueTrackAdded>(_onTrackAdded);
  }
  _onInit(QueueInitial event, Emitter<QueueState> emit) {}

  _onTrackAdded(QueueTrackAdded event, Emitter<QueueState> emit) {
    emit(state..queue.add(event.track));
  }
}
