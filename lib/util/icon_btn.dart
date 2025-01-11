import 'package:elbe/elbe.dart';
import 'package:macos_ui/macos_ui.dart';

final cAction = Colors.white.withOpacity(.06);
final cActionPressed = Colors.white.withOpacity(.125);

class AIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final void Function()? onTap;

  const AIconButton(
      {super.key,
      required this.icon,
      required this.tooltip,
      required this.onTap});

  @override
  State<AIconButton> createState() => _IconButtonState();
}

class _IconButtonState extends State<AIconButton> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.onTap == null ? .4 : 1,
      child: MacosTooltip(
        message: widget.tooltip,
        child: GestureDetector(
            onTapDown: (_) =>
                widget.onTap == null ? null : setState(() => pressed = true),
            onTapUp: (_) => setState(() => pressed = false),
            onTapCancel: () => setState(() => pressed = false),
            onTap: widget.onTap,
            child: Box(
                border: Border(
                    pixelWidth: 0,
                    borderRadius: BorderRadius.circular(context.rem(5))),
                color: pressed ? cActionPressed : cAction,
                padding: const RemInsets.all(1),
                child: Icon(widget.icon))),
      ),
    );
  }
}

class ATextButton extends StatefulWidget {
  final IconData? icon;
  final String label;
  final Color? color;
  final void Function() onTap;

  const ATextButton(
      {super.key,
      this.icon,
      required this.label,
      this.color,
      required this.onTap});

  @override
  State<ATextButton> createState() => _ATextButtonState();
}

class _ATextButtonState extends State<ATextButton> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTapDown: (_) => setState(() => pressed = true),
        onTapUp: (_) => setState(() => pressed = false),
        onTapCancel: () => setState(() => pressed = false),
        onTap: widget.onTap,
        child: Box(
            border: Border.none,
            color: pressed
                ? (widget.color?.inter(Colors.white, .15) ?? cActionPressed)
                : (widget.color ?? cAction),
            padding: const RemInsets.all(1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) Icon(widget.icon),
                Text.bodyM(widget.label, variant: TypeVariants.bold),
              ].spaced(amount: .5),
            )));
  }
}
