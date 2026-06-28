import 'package:avo_app/app/core/Language/locale_keys.g.dart';
import 'package:avo_app/app/core/routing/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppExitPopScope extends StatefulWidget {
  final Widget child;

  const AppExitPopScope({
    super.key,
    required this.child,
  });

  @override
  State<AppExitPopScope> createState() => _AppExitPopScopeState();
}

class _AppExitPopScopeState extends State<AppExitPopScope> {
  bool _isDialogShowing = false;

  Future<void> _onPopInvoked(bool didPop) async {
    if (didPop || _isDialogShowing) return;

    if (AppRouter.router.canPop()) {
      AppRouter.router.pop();
      return;
    }

    _isDialogShowing = true;

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(dialogContext).scaffoldBackgroundColor,
          title: Text(
            LocaleKeys.general_exit_title.tr(),
            style: TextStyle(
              color: Theme.of(dialogContext).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            LocaleKeys.general_exit_confirm.tr(),
            style: TextStyle(
              color: Theme.of(dialogContext).colorScheme.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                LocaleKeys.general_no.tr(),
                style: TextStyle(
                  color: Theme.of(dialogContext).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                LocaleKeys.general_yes.tr(),
                style: TextStyle(
                  color: Theme.of(dialogContext).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    _isDialogShowing = false;

    if (shouldExit == true) {
      await SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => _onPopInvoked(didPop),
      child: widget.child,
    );
  }
}