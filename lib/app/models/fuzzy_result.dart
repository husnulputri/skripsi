import 'package:nylo_framework/nylo_framework.dart';

class FuzzyResult extends Model {

  static StorageKey key = "fuzzy_result";
  
  FuzzyResult() : super(key: key);
  
  FuzzyResult.fromJson(data) : super(key: key) {

  }

  @override
  toJson() {
    return {};
  }
}
