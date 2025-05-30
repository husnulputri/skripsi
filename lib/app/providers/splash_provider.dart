import 'package:nylo_framework/nylo_framework.dart';

class SplashProvider implements NyProvider {
  @override
  boot(Nylo nylo) async {
    await sleep(3);
    return nylo;
  }

  @override
  afterBoot(Nylo nylo) async {
    // Called after Nylo has finished booting
    // ...
  }
}
