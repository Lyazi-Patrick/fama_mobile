/// Laravel often serializes 'decimal' cast columns (price, latitude,
/// longitude, etc.) as JSON strings rather than numbers (e.g. "1200.00"
/// instead of 1200.00). These helpers parse either shape safely instead of
/// assuming `json['field'] as num`, which throws when the API sends a string.
double asDouble(dynamic value, {double fallback = 0}) {
  if (value == null) return fallback;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

double? asDoubleOrNull(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

int asInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}
