import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:muller_package/app_components/app_snack_bar.dart';
import 'package:muller_package/app_consts/app_context.dart';
import 'package:muller_package/app_consts/app_strings.dart';
import 'package:web_gestor_site_covertix/widgets/web_toast_popup.dart';

class AppToast {
  AppToast._();

  static OverlayEntry? _entry;
  static Timer? _timer;

  static void show({
    required String message,
    WebToastType type = WebToastType.success,
    Duration duration = const Duration(seconds: 4),
  }) {
    if (!kIsWeb) return;

    _hide();

    final overlay = AppContext.navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _WebToastOverlay(
        message: message,
        type: type,
        onDismiss: () {
          if (_entry == entry) {
            _entry = null;
            _timer?.cancel();
          }
          entry.remove();
        },
      ),
    );

    _entry = entry;
    overlay.insert(entry);

    _timer = Timer(duration, () {
      if (_entry == entry) {
        entry.remove();
        _entry = null;
      }
    });
  }

  static void _hide() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
  }
}

class _WebToastOverlay extends StatefulWidget {
  final String message;
  final WebToastType type;
  final VoidCallback onDismiss;

  const _WebToastOverlay({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  State<_WebToastOverlay> createState() => _WebToastOverlayState();
}

class _WebToastOverlayState extends State<_WebToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0.15, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 24,
      bottom: 24,
      child: SafeArea(
        child: SlideTransition(
          position: _slide,
          child: FadeTransition(
            opacity: _fade,
            child: WebToastPopup(
              message: widget.message,
              type: widget.type,
              onClose: _close,
            ),
          ),
        ),
      ),
    );
  }
}

void showToastSuccess({required String message}) {
  if (kIsWeb) {
    AppToast.show(message: message, type: WebToastType.success);
    return;
  }
  showSnackbarSuccess(message: message);
}

void showToastError({String? message}) {
  if (kIsWeb) {
    AppToast.show(
      message: message ?? AppStrings.ocorreuUmErro,
      type: WebToastType.error,
    );
    return;
  }
  showSnackbarError(message: message);
}

void showToastWarning({required String message}) {
  if (kIsWeb) {
    AppToast.show(message: message, type: WebToastType.warning);
    return;
  }
  showSnackbarWarning(message: message);
}
