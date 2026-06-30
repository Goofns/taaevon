/// Maps the learner's current Dynamic Difficulty Calibration math [band] to the
/// maximum fact complexity (1-5) they should be shown, so the micro-learning
/// facts scale with their level instead of using a fixed ceiling (PRD §6.2).
///
/// One step of headroom above the rounded band, clamped to the 1-5 range: a
/// beginner (band ~1) sees up to complexity 2; a calculus-level learner (band 3)
/// up to 4; post-grad (band 4-5) the full range.
int factComplexityCeiling(double band) => (band.round() + 1).clamp(1, 5);
