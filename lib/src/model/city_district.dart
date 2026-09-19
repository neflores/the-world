/// A semantic direction within a city, never a real street coordinate.
enum CityDistrict {
  north('North'),
  northEast('North-east'),
  east('East'),
  southEast('South-east'),
  south('South'),
  southWest('South-west'),
  west('West'),
  northWest('North-west'),
  center('Center');

  const CityDistrict(this.label);
  final String label;
  int get plotsPerNeighborhood => this == center ? 2 : 6;
}
