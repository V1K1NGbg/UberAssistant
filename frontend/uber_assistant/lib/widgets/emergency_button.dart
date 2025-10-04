import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';

/// bottom-left red square that reveals a top-right "112" phone icon strip
class EmergencyButton extends StatefulWidget {
  const EmergencyButton({super.key});

  @override
  State<EmergencyButton> createState() => _EmergencyButtonState();
}

class _EmergencyButtonState extends State<EmergencyButton> with SingleTickerProviderStateMixin {
  bool _expanded = false;

  Future<void> _openDialer() async {
    final uri = Uri(scheme: 'tel', path: K.emergencyNumber);
    final ok = await canLaunchUrl(uri);
    if (!ok) {
      // still try to launch; if it fails, we just ignore
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Couldn't open dialer")));
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stripBg = isDark ? Colors.white : Colors.black; // high-contrast strip
    final iconColor = isDark ? Colors.black : Colors.white; // per your request

    return SizedBox(
      width: K.emergencyButtonSize,
      height: K.emergencyButtonSize + 40, // room for the strip
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // red square
          Positioned(
            left: 0, bottom: 0,
            child: GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Container(
                width: K.emergencyButtonSize,
                height: K.emergencyButtonSize,
                decoration: BoxDecoration(
                  color: K.dangerRed,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.white),
              ),
            ),
          ),

          // revealed strip (slides UP, top-right "112", call icon bottom-right)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            left: 0,
            bottom: _expanded ? K.emergencyButtonSize + 6 : K.emergencyButtonSize - 10,
            child: IgnorePointer(
              ignoring: !_expanded,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: _expanded ? 1 : 0,
                child: Container(
                  width: K.emergencyButtonSize,
                  height: 40,
                  decoration: BoxDecoration(
                    color: stripBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: stripBg.withOpacity(0.6), width: 1),
                  ),
                  child: Stack(
                    children: [
                      // 112 small, top-right
                      Positioned(
                        top: 6,
                        right: 8,
                        child: Text(K.emergencyNumber,
                            style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700,
                              color: iconColor,
                            )),
                      ),
                      // phone icon bottom-right (the tappable area)
                      Positioned(
                        right: 6, bottom: 4,
                        child: GestureDetector(
                          onTap: _openDialer,
                          behavior: HitTestBehavior.translucent,
                          child: Icon(Icons.phone_in_talk_rounded, size: 22, color: iconColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
