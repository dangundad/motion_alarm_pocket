import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../theme/app_theme.dart';

/// The four visual states the dial renders. Mapped from the controller flags
/// once so painters and labels stay consistent.
enum ArmDialState { disarmed, arming, armed, alarm }

/// Signature hero: a large tap-to-arm power dial.
///
/// - DISARMED: a dim steel ring around a power icon.
/// - ARMING: the ring fills clockwise as the start-delay counts down.
/// - ARMED: the ring breathes amber; a thin reactive arc shows live motion.
/// - ALARM: the whole dial flashes crimson.
///
/// Tapping anywhere on the dial is the primary arm/disarm action.
class ArmDial extends StatefulWidget {
  const ArmDial({
    super.key,
    required this.state,
    required this.armingProgress,
    required this.motion,
    required this.onTap,
  });

  final ArmDialState state;

  /// 0..1 countdown fill while ARMING.
  final double armingProgress;

  /// 0..1 normalized live motion delta while ARMED (drives the reactive arc).
  final double motion;

  final VoidCallback onTap;

  @override
  State<ArmDial> createState() => _ArmDialState();
}

class _ArmDialState extends State<ArmDial> with TickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    // Drives the breathing (armed) and flashing (alarm) animations. Runs
    // continuously; painters read its value only in the relevant state.
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Color _coreColor() {
    switch (widget.state) {
      case ArmDialState.alarm:
        return AppTheme.alarm;
      case ArmDialState.armed:
        return AppTheme.armed;
      case ArmDialState.arming:
        return AppTheme.arming;
      case ArmDialState.disarmed:
        return AppTheme.disarmed;
    }
  }

  IconData _icon() {
    switch (widget.state) {
      case ArmDialState.alarm:
        return LucideIcons.siren;
      case ArmDialState.armed:
        return LucideIcons.shieldCheck;
      case ArmDialState.arming:
        return LucideIcons.timer;
      case ArmDialState.disarmed:
        return LucideIcons.power;
    }
  }

  String _label() {
    switch (widget.state) {
      case ArmDialState.alarm:
        return 'state_alarm'.tr;
      case ArmDialState.armed:
        return 'state_armed'.tr;
      case ArmDialState.arming:
        return 'state_arming'.tr;
      case ArmDialState.disarmed:
        return 'state_disarmed'.tr;
    }
  }

  String _hint() {
    switch (widget.state) {
      case ArmDialState.alarm:
        return 'dial_hint_alarm'.tr;
      case ArmDialState.armed:
        return 'dial_hint_armed'.tr;
      case ArmDialState.arming:
        return 'dial_hint_arming'.tr;
      case ArmDialState.disarmed:
        return 'dial_hint_disarmed'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final core = _coreColor();
    final size = 260.r;
    final isAlarm = widget.state == ArmDialState.alarm;
    final isArmed = widget.state == ArmDialState.armed;

    return Semantics(
      button: true,
      label: '${_label()}. ${_hint()}',
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: size,
          height: size,
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) {
              // Breathing/flashing factor: alarm flashes hard, armed breathes
              // gently, other states stay steady.
              final wave = _pulse.value; // 0..1
              final double glow = isAlarm
                  ? 0.45 + 0.55 * wave
                  : isArmed
                      ? 0.30 + 0.30 * wave
                      : 0.0;
              final double coreScale = isAlarm
                  ? 1.0 + 0.04 * wave
                  : isArmed
                      ? 1.0 + 0.015 * wave
                      : 1.0;

              return CustomPaint(
                painter: _DialPainter(
                  state: widget.state,
                  core: core,
                  trackColor: Theme.of(context).colorScheme.outlineVariant,
                  armingProgress: widget.armingProgress,
                  motion: widget.motion,
                  glow: glow,
                  wave: wave,
                ),
                child: Center(
                  child: Transform.scale(
                    scale: coreScale,
                    child: _DialCore(
                      core: core,
                      glow: glow,
                      icon: _icon(),
                      label: _label(),
                      hint: _hint(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DialCore extends StatelessWidget {
  const _DialCore({
    required this.core,
    required this.glow,
    required this.icon,
    required this.label,
    required this.hint,
  });

  final Color core;
  final double glow;
  final IconData icon;
  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 168.r,
      height: 168.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Color.alphaBlend(core.withAlpha((110 * glow).round()), cs.surface),
            cs.surface,
          ],
          radius: 0.95,
        ),
        border: Border.all(color: core.withAlpha(150), width: 2),
        boxShadow: glow > 0
            ? [
                BoxShadow(
                  color: core.withAlpha((140 * glow).round()),
                  blurRadius: 36,
                  spreadRadius: 4,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 46.r, color: core),
          SizedBox(height: 8.h),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.rajdhani(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
              color: core,
            ),
          ),
          SizedBox(height: 2.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              hint,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.sp,
                height: 1.2,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  _DialPainter({
    required this.state,
    required this.core,
    required this.trackColor,
    required this.armingProgress,
    required this.motion,
    required this.glow,
    required this.wave,
  });

  final ArmDialState state;
  final Color core;
  final Color trackColor;
  final double armingProgress;
  final double motion;
  final double glow;
  final double wave;

  static const double _start = -math.pi / 2; // 12 o'clock

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 14;
    final stroke = 12.0;

    // Base track ring.
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = trackColor.withAlpha(120);
    canvas.drawCircle(center, radius, track);

    final rect = Rect.fromCircle(center: center, radius: radius);

    switch (state) {
      case ArmDialState.disarmed:
        // A short steel hint arc at the top.
        final hint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..color = core.withAlpha(120);
        canvas.drawArc(rect, _start, math.pi / 6, false, hint);
        break;

      case ArmDialState.arming:
        // Fill clockwise as the countdown progresses.
        final fill = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..color = core;
        canvas.drawArc(
          rect,
          _start,
          2 * math.pi * armingProgress.clamp(0.0, 1.0),
          false,
          fill,
        );
        break;

      case ArmDialState.armed:
        // Full breathing ring + a thin reactive motion arc inside it.
        final ring = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..color = core.withAlpha((150 + 80 * glow).round().clamp(0, 255));
        canvas.drawCircle(center, radius, ring);

        final reactive = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round
          ..color = AppTheme.arming
              .withAlpha((120 + 135 * motion).round().clamp(0, 255));
        final reactiveRect =
            Rect.fromCircle(center: center, radius: radius - stroke - 4);
        // Arc length grows with live motion (min visible sweep so it reads).
        final sweep = (0.06 + 0.9 * motion.clamp(0.0, 1.0)) * math.pi;
        canvas.drawArc(reactiveRect, _start, sweep, false, reactive);
        break;

      case ArmDialState.alarm:
        // Hard crimson ring that pulses with the flash.
        final ring = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke + 2 * wave
          ..strokeCap = StrokeCap.round
          ..color = core;
        canvas.drawCircle(center, radius, ring);
        // Outer flash halo.
        final halo = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = core.withAlpha((150 * glow).round().clamp(0, 255));
        canvas.drawCircle(center, radius + 8, halo);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _DialPainter old) =>
      old.state != state ||
      old.armingProgress != armingProgress ||
      old.motion != motion ||
      old.glow != glow ||
      old.wave != wave ||
      old.core != core;
}
