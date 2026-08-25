import 'package:elbe/elbe.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:wad/util/util.dart';

const BTN_ALPHA = .25;
const RADIUS_SMALL = 3.0;
const RADIUS_LARGE = 7.0;

class WADButton extends StatefulWidget {
  final ColorKinds? kind;
  final void Function()? onTap;
  final String tooltip;
  final String? label;
  final IconData? icon;
  final double _padding;
  final double _minHeight;
  final double? _borderRadius;

  const WADButton.text(
      {super.key,
      this.kind,
      required this.onTap,
      required this.label,
      this.icon,
      required this.tooltip})
      : _padding = .75,
        _minHeight = 3,
        _borderRadius = null;

  const WADButton.icon(
      {super.key,
      this.kind,
      required this.onTap,
      required this.icon,
      required this.tooltip})
      : _padding = .5,
        _minHeight = 3.5,
        label = null,
        _borderRadius = 5;

  @override
  State<WADButton> createState() => _AppleButtonBaseState();
}

class _AppleButtonBaseState extends State<WADButton> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final loud = widget.kind != null;
    final disabled = widget.onTap == null;
    final selColor = context.theme.color.resolve(
      kind: widget.kind,
      state: disabled
          ? pressed
              ? ColorStates.active
              : ColorStates.neutral
          : ColorStates.disabled,
      manner: loud ? ColorManners.major : ColorManners.plain,
    );

    return GestureDetector(
        onTapDown: (_) => setState(() => pressed = true),
        onTapUp: (_) => setState(() => pressed = false),
        onTapCancel: () => setState(() => pressed = false),
        onTap: widget.onTap,
        child: MacosTooltip(
          message: "${widget.tooltip}${disabled ? " (disabled)" : ""}",
          child: Card(
              constraints: RemConstraints(
                  minHeight: widget._minHeight, minWidth: widget._minHeight),
              border: Border.none,
              radius: widget._borderRadius,
              kind: widget.kind,
              state: pressed ? ColorStates.active : ColorStates.neutral,
              manner: loud ? ColorManners.major : ColorManners.plain,
              color: loud
                  ? null
                  : selColor.back.withTranslucency(disabled ? .125 : BTN_ALPHA),
              padding: RemInsets.all(widget._padding),
              child: Row(
                cross: CrossAxisAlignment.center,
                main: MainAxisAlignment.center,
                gap: .5,
                children: [
                  if (widget.icon != null) Icon(widget.icon),
                  if (widget.label != null)
                    Text.bodyM(widget.label ?? "", variant: TypeVariants.bold),
                ],
              )),
        ));
  }
}
