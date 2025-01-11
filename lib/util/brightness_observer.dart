import 'package:elbe/elbe.dart';

class BrightnessObserver extends StatefulWidget {
  final Widget child;
  const BrightnessObserver({super.key, required this.child});

  @override
  createState() => _State();
}

class _State extends State<BrightnessObserver> with WidgetsBindingObserver {
  Brightness _brightness = Brightness.light;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _brightness = WidgetsBinding.instance.window.platformBrightness;
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {
      _brightness = WidgetsBinding.instance.window.platformBrightness;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Box(
      mode:
          _brightness == Brightness.light ? ColorModes.light : ColorModes.dark,
      color: Colors.transparent,
      child: widget.child);
}
