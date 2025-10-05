import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';

/// Red square that reveals a call panel which grows/shrinks
/// from *under* the red button. The panel's background extends
/// beneath the red button; on collapse it disappears *into* it.
class EmergencyButton extends StatefulWidget {
  const EmergencyButton({super.key});

  @override
  State<EmergencyButton> createState() => _EmergencyButtonState();
}

class _EmergencyButtonState extends State<EmergencyButton> with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;
  late final Animation<double> _size;
  late final Animation<double> _fade;

  bool _expanded = false;

  // layout tuning
  static const double _corner = 14;
  static const double _panelHeight = 84;   // visible area above the red button
  static const double _underlap    = 12;   // part that continues under the red button

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _size = CurvedAnimation(parent: _ctl, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
    _fade = CurvedAnimation(parent: _ctl, curve: Curves.easeOut, reverseCurve: Curves.easeIn);
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  Future<void> _openDialer() async {
    final uri = Uri(scheme: 'tel', path: K.emergencyNumber);
    if (!await canLaunchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't open dialer")),
        );
      }
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _ctl.forward();
    } else {
      _ctl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme    = Theme.of(context).colorScheme;
    final panelBg   = scheme.surface;
    final panelText = scheme.onSurface;

    // reserve enough space so we never overflow while animating
    return SizedBox(
      width: K.emergencyButtonSize,
      height: K.emergencyButtonSize + _panelHeight + 8,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ---------------- PANEL (behind the red button) ----------------
          // Bottom is set so the panel extends UNDER the red button by [_underlap].
          Positioned(
            left: 0,
            bottom: K.emergencyButtonSize - _underlap,
            child: IgnorePointer(
              ignoring: !_expanded && _ctl.isDismissed,
              child: FadeTransition(
                opacity: _fade,
                child: SizeTransition(
                  sizeFactor: _size,
                  axis: Axis.vertical,
                  axisAlignment: 1.0, // anchor to bottom → grows/shrinks upward into the red button
                  child: Container(
                    width: K.emergencyButtonSize,
                    height: _panelHeight + _underlap, // includes the portion that sits under the red button
                    decoration: BoxDecoration(
                      color: panelBg,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(_corner),
                        topRight: Radius.circular(_corner),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.24),
                          blurRadius: 10,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.only(
                      left: 12,
                      right: 12,
                      // keep content above the overlapped zone + give it some breathing room
                      bottom: _underlap + 10,
                      top: 12,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(_corner),
                          topRight: Radius.circular(_corner),
                        ),
                        onTap: _openDialer,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 112 ABOVE the icon
                            Text(
                              K.emergencyNumber,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: panelText,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Icon(Icons.phone_in_talk_rounded, size: 28, color: panelText),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ---------------- RED BUTTON (on top) ----------------
          Positioned(
            left: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: _toggle,
              child: Container(
                width: K.emergencyButtonSize,
                height: K.emergencyButtonSize,
                decoration: BoxDecoration(
                  color: K.dangerRed,
                  borderRadius: BorderRadius.circular(_corner),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
