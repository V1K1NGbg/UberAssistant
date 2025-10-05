import 'dart:async';
import 'package:flutter/material.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:uber_assistant/l10n/app_localizations.dart';
import '../constants.dart';
import '../models/customer_request.dart';
import '../models/customer.dart';
import 'rating_stars.dart';

class RideRequestSheet extends StatefulWidget {
  final CustomerRequest request;
  final Customer? customer;
  final void Function() onSkip;
  final void Function() onAccept;
  const RideRequestSheet({
    super.key,
    required this.request,
    required this.customer,
    required this.onSkip,
    required this.onAccept,
  });

  @override
  State<RideRequestSheet> createState() => _RideRequestSheetState();
}

class _RideRequestSheetState extends State<RideRequestSheet> {
  late int _remaining = K.offerTimeoutSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _remaining--);
      if (_remaining <= 0) {
        t.cancel();
        Navigator.of(context).maybePop();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final adviceRaw = widget.request.advice?.toLowerCase().trim();
    final hasAdvice = adviceRaw == 'yes' || adviceRaw == 'no';
    final isYes = adviceRaw == 'yes';

    final title = hasAdvice && isYes ? t.requestTitleRecommended : t.requestTitle;

    return SafeArea(
      child: Material( // opaque to prevent underlying icons showing "on top"
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(K.corner)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade500, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  if (hasAdvice) ...[
                    const SizedBox(width: 10),
                    _advicePill(isYes),
                  ],
                  const Spacer(),
                  Text(t.expiresIn(_remaining), style: Theme.of(context).textTheme.labelLarge),
                ],
              ),
              if (hasAdvice) ...[
                const SizedBox(height: 8),
                _adviceBanner(isYes),
              ],
              const SizedBox(height: 12),
              _kv(
                t.customer,
                widget.customer?.name ?? '—',
                trailing: widget.customer == null
                    ? const Icon(Icons.error, color: Colors.red)
                    : RatingStars(rating: widget.customer!.rating),
              ),
              const SizedBox(height: 8),
              _kv(
                t.pickup,
                widget.request.from.address ??
                    '${widget.request.from.lat}, ${widget.request.from.lon}',
                sub:
                '(${widget.request.from.lat.toStringAsFixed(5)}, ${widget.request.from.lon.toStringAsFixed(5)})',
              ),
              const SizedBox(height: 8),
              _kv(
                t.dropoff,
                widget.request.to.address ??
                    '${widget.request.to.lat}, ${widget.request.to.lon}',
                sub:
                '(${widget.request.to.lat.toStringAsFixed(5)}, ${widget.request.to.lon.toStringAsFixed(5)})',
              ),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _pill(Icons.timer, t.durationLabel, t.mins(widget.request.durationMins.round()))),
                const SizedBox(width: 8),
                Expanded(child: _pill(Icons.euro, t.earningsLabel, '€${widget.request.price.toStringAsFixed(2)}')),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _remaining > 0
                        ? () {
                      widget.onSkip();
                      if (mounted) Navigator.of(context).maybePop();
                    }
                        : null,
                    icon: const Icon(Icons.close),
                    label: Text(t.skip),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      return SlideAction(
                        sliderRotate: false,
                        elevation: 0,
                        borderRadius: K.corner,
                        outerColor: K.safetyBlue,
                        innerColor: Colors.white,
                        text: t.accept,
                        textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        onSubmit: () async {
                          widget.onAccept();
                          if (mounted) Navigator.of(context).maybePop();
                        },
                      );
                    },
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _advicePill(bool yes) {
    final color = yes ? K.successGreen : K.errorRed;
    final text = yes ? 'Advice: YES' : 'Advice: NO';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _adviceBanner(bool yes) {
    final color = yes ? K.successGreen : K.errorRed;
    final icon  = yes ? Icons.thumb_up_alt_rounded : Icons.thumb_down_alt_rounded;
    final msg   = yes ? 'We recommend accepting this request.' : 'We recommend skipping this request.';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(msg, style: TextStyle(color: color, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _kv(String k, String v, {Widget? trailing, String? sub}) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 88, child: Text(k, style: theme.textTheme.labelLarge?.copyWith(color: theme.hintColor))),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(v, style: theme.textTheme.titleMedium),
              if (sub != null) Text(sub, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _pill(IconData icon, String k, String v) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(K.corner),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(k),
          const Spacer(),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
