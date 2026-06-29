import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../progress/cubit/progress_cubit.dart';
import '../streak/cubit/streak_cubit.dart';

/// Records one activity completion from an activity screen's completion-state
/// listener: bumps the per-activity count and updates the day streak. The two
/// root cubits are read from [context].
void recordActivityCompletion(BuildContext context, String activityId) {
  context.read<ProgressCubit>().recordCompletion(activityId);
  context.read<StreakCubit>().recordActivity();
}
