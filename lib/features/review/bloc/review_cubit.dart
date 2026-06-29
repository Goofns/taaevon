import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../language/data/lexicon_repository.dart';
import '../../language/domain/lexicon_entry.dart';
import '../data/review_store.dart';
import '../domain/review_schedule.dart';

sealed class ReviewState extends Equatable {
  const ReviewState();
  @override
  List<Object?> get props => [];
}

class ReviewInitial extends ReviewState {
  const ReviewInitial();
}

class ReviewLoading extends ReviewState {
  const ReviewLoading();
}

/// Nothing is due for review right now.
class ReviewEmpty extends ReviewState {
  const ReviewEmpty();
}

class ReviewInProgress extends ReviewState {
  const ReviewInProgress({
    required this.current,
    required this.revealed,
    required this.done,
    required this.total,
  });

  final LexiconEntry current;
  final bool revealed;
  final int done; // graded so far
  final int total; // session size

  @override
  List<Object?> get props => [current.wordId, revealed, done, total];
}

class ReviewComplete extends ReviewState {
  const ReviewComplete({required this.reviewed});
  final int reviewed;
  @override
  List<Object?> get props => [reviewed];
}

/// A spaced-repetition review session over due vocabulary, driven by the SM-2
/// scheduler. Per-word schedules persist between sessions; the clock is
/// injectable for testability.
class ReviewCubit extends Cubit<ReviewState> {
  ReviewCubit({
    required LexiconRepository lexicon,
    ReviewStore? store,
    Random? random,
    DateTime Function()? clock,
  })  : _lexicon = lexicon,
        _store = store ?? InMemoryReviewStore(),
        _rng = random ?? Random(),
        _clock = clock ?? DateTime.now,
        super(const ReviewInitial());

  final LexiconRepository _lexicon;
  final ReviewStore _store;
  final Random _rng;
  final DateTime Function() _clock;

  static const int sessionSize = 10;

  Map<String, ReviewSchedule> _schedules = {};
  List<LexiconEntry> _queue = const [];
  int _index = 0;

  Future<void> start(String targetLanguage) async {
    emit(const ReviewLoading());
    final raw = await _store.load();
    if (isClosed) return; // screen popped mid-load — never emit after close
    _schedules = raw.map(
      (k, v) => MapEntry(k, ReviewSchedule.fromMap(v as Map<String, dynamic>)),
    );

    final now = _clock();
    final due = (await _lexicon.entriesForTarget(targetLanguage))
        .where((e) => ReviewScheduler.isDue(_schedules[e.wordId], now))
        .toList()
      ..shuffle(_rng);
    if (isClosed) return; // screen popped mid-load — never emit after close

    _queue = due.take(sessionSize).toList();
    _index = 0;
    if (_queue.isEmpty) {
      emit(const ReviewEmpty());
      return;
    }
    emit(_inProgress(revealed: false));
  }

  void reveal() {
    if (state is ReviewInProgress) emit(_inProgress(revealed: true));
  }

  /// Grade recall on the SM-2 0–5 scale and advance.
  void grade(int quality) {
    if (state is! ReviewInProgress) return;
    final word = _queue[_index];
    _schedules[word.wordId] =
        ReviewScheduler.grade(_schedules[word.wordId], quality, _clock());
    unawaited(_persist());

    _index += 1;
    if (_index >= _queue.length) {
      emit(ReviewComplete(reviewed: _queue.length));
      return;
    }
    emit(_inProgress(revealed: false));
  }

  ReviewInProgress _inProgress({required bool revealed}) => ReviewInProgress(
        current: _queue[_index],
        revealed: revealed,
        done: _index,
        total: _queue.length,
      );

  Future<void> _persist() =>
      _store.save(_schedules.map((k, v) => MapEntry(k, v.toMap())));
}
