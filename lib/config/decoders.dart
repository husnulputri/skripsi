import '/app/models/fuzzy_result.dart';
import '/app/controllers/home_page_controller.dart';
import '/app/models/home.dart';
import '/app/controllers/home_screen_controller.dart';
// import '/app/controllers/home_controller.dart';
import '/app/models/user.dart';
import '/app/networking/api_service.dart';

/* Model Decoders
|--------------------------------------------------------------------------
| Model decoders are used in 'app/networking/' for morphing json payloads
| into Models.
|
| Learn more https://nylo.dev/docs/6.x/decoders#model-decoders
|-------------------------------------------------------------------------- */

final Map<Type, dynamic> modelDecoders = {
  Map<String, dynamic>: (data) => Map<String, dynamic>.from(data),

  List<User>: (data) =>
      List.from(data).map((json) => User.fromJson(json)).toList(),
  //
  User: (data) => User.fromJson(data),

  // User: (data) => User.fromJson(data),

  List<Home>: (data) =>
      List.from(data).map((json) => Home.fromJson(json)).toList(),

  Home: (data) => Home.fromJson(data),

  List<FuzzyResult>: (data) => List.from(data).map((json) => FuzzyResult.fromJson(json)).toList(),

  FuzzyResult: (data) => FuzzyResult.fromJson(data),
};

/* API Decoders
| -------------------------------------------------------------------------
| API decoders are used when you need to access an API service using the
| 'api' helper. E.g. api<MyApiService>((request) => request.fetchData());
|
| Learn more https://nylo.dev/docs/6.x/decoders#api-decoders
|-------------------------------------------------------------------------- */

final Map<Type, dynamic> apiDecoders = {
  ApiService: () => ApiService(),

  // ...
};

/* Controller Decoders
| -------------------------------------------------------------------------
| Controller are used in pages.
|
| Learn more https://nylo.dev/docs/6.x/controllers
|-------------------------------------------------------------------------- */
final Map<Type, dynamic> controllers = {
  // HomeController: () => HomeController(),

  // ...

  HomeScreenController: () => HomeScreenController(),

  HomePageController: () => HomePageController(),
};
