/// Public backend projection. World does not calculate rewards or progression.
class CityGlory {
  const CityGlory({
    this.level = 0,
    this.progress = 0,
    this.title = '',
    this.season = '',
  }) : assert(level >= 0),
       assert(progress >= 0 && progress <= 1);
  final int level;
  final double progress;
  final String title, season;
}
