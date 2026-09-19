import 'city_district.dart';
import 'world_appearance.dart';

class ClubDraft {
  const ClubDraft({
    required this.cityId,
    required this.name,
    required this.address,
    required this.district,
    this.description = '',
    this.appearance = const WorldAppearance(),
  });
  final String cityId, name, address, description;
  final CityDistrict district;
  final WorldAppearance appearance;
  String? get validationError {
    if (cityId.trim().isEmpty) return 'Choose a city.';
    if (name.trim().isEmpty || name.trim().length > 60) {
      return 'Enter a club name (1–60 characters).';
    }
    if (address.trim().length < 5 || address.trim().length > 200) {
      return 'Enter a full street address (5–200 characters).';
    }
    if (description.length > 300) {
      return 'Keep the description under 300 characters.';
    }
    return null;
  }
}
