import 'package:app/data/user.dart';
import 'package:app/services/api_service.dart';
import 'package:app/widgets/error_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/user_provider.dart';
import 'package:app/widgets/profile_page/dialog_buttons.dart';

class LogoutConfirmationDialog extends StatelessWidget {
  const LogoutConfirmationDialog({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final navigator = Navigator.of(context);
    
    final userProvider = context.read<UserProvider>();
    User user = userProvider.user!;
    final apiService = ApiService(user.tokens);

    try {
      final response = await apiService.dio.post(
        '/api/auth/logout',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${user.tokens.accessToken}',
            'Refresh-Token': '${user.tokens.refreshToken}',
            },
        )
      );

      if (response.statusCode == 200) {
        userProvider.logout();
        navigator.pop();
      } else {
        if (!context.mounted) return;
        ErrorDialog.show(
          context: context,
          message: 'Failed to log out. Please try again.',
          title: 'Logout Error',
          buttonText: 'OK',
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ErrorDialog.show(
        context: context,
        message: 'An error occurred while logging out. Please try again.',
        title: 'Logout Error',
        buttonText: 'OK',
      );
    }
 
    
    
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _buildTitle(),
      content: _buildDescription(),
      actions: [
        Row(
          children: [
            Expanded(
              child: buildOutlinedDialogButton(
                label: 'Cancel',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: buildElevatedDialogButton(
                label: 'Log out',
                onPressed: () => _handleLogout(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return const Center(
      child: Text('Log out', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDescription() {
    return const Text(
      "Are you sure you want to log out? You'll need to login again to use the app.",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 15,
        color: Colors.grey,
        fontWeight: FontWeight.w500,
        height: 1.3,
      ),
    );
  }
}
