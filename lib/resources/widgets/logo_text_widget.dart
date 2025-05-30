import 'package:flutter/material.dart';
import 'package:flutter_app/config/colors_config.dart';
import 'package:nylo_framework/nylo_framework.dart';

class LogoText extends StatefulWidget {
  const LogoText({super.key});

  @override
  createState() => _LogoTextState();
}

class _LogoTextState extends NyState<LogoText> {
  @override
  get init => () {};

  @override
  Widget view(BuildContext context) {
    return Container(
      child: Text(
        'Polije Nursery',
        style: TextStyle(
          fontSize: 28,
          color: SetColors.Coklat,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
