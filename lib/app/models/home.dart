import 'package:nylo_framework/nylo_framework.dart';

class Home extends Model {

  static StorageKey key = "home";
  
  Home() : super(key: key);
  
  Home.fromJson(data) : super(key: key) {

  }

  @override
  toJson() {
    return {};
  }
}
