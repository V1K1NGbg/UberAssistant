import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';

/// Bottom-left red square that reveals an expanding call panel
/// The white/dark panel animates UP from under the red button,
/// and its background continues under the red button (panel is drawn behind it).
class EmergencyButton extends StatefulWidget {
  const EmergencyButton({super.key});

  @override
  State<EmergencyButton> createState() => _EmergencyButtonState();
}

class _EmergencyButtonState extends State<EmergencyButton> {
  bool _expanded = false;

  static const double _corner = 14;
  static const double _panelHeight = 68; // height of the revealed call panel

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

  void _toggle() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final panelColor = theme.colorScheme.surface;        // light/dark aware
    final textColor  = theme.colorScheme.onSurface;

    // total height allows the panel to expand above the red button
    return SizedBox(
      width: K.emergencyButtonSize,
      height: K.emergencyButtonSize + _panelHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // --- EXPANDING CALL PANEL (behind the red button) ---
          Positioned(
            left: 0,
            bottom: 0, // panel grows upward from the bottom edge (under the red button)
            child: IgnorePointer(
              ignoring: !_expanded,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                width: K.emergencyButtonSize,
                height: _expanded ? _panelHeight : 0,
                decoration: BoxDecoration(
                  color: panelColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(_corner),
                    topRight: Radius.circular(_corner),
                  ),
                  boxShadow: [
                    // subtle lift; still visible in dark mode
                    BoxShadow(
                      color: Colors.black.withOpacity(0.24),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                // fade in content as it expands
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: _expanded ? 1 : 0,
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
                          Icon(Icons.phone_in_talk_rounded, size: 26, color: textColor),
                          const SizedBox(height: 6),
                          Text(
                            K.emergencyNumber,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // --- RED EMERGENCY BUTTON (on top) ---
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
