import 'package:flutter/material.dart';
import 'package:app/widgets/profile_page/dialog_buttons.dart';

class DeleteAccountDialog extends StatelessWidget {
  const DeleteAccountDialog({super.key});

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
                label: 'Delete',
                onPressed: () {
                  Navigator.of(context).pop();
                  _showDeleteConfirmationInputDialog(context);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return const Center(
      child: Text(
        'Delete Account',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDescription() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Are you sure you want to delete your account permanently?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'If you no longer wish to use Kwik Report, you can permanently delete your account.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmationInputDialog(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscurePassword = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final theme = Theme.of(context);
            return AlertDialog(
              title: const Center(
                child: Text(
                  'Delete Account',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'WARNING',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    Text(
                      'This is permanent and cannot be undone!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildLabel(theme, 'Confirm your Email'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        hintText: 'Email Address',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Please enter your email'
                                  : null,
                    ),
                    const SizedBox(height: 12),
                    _buildLabel(theme, 'Confirm your Password'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        border: const OutlineInputBorder(),
                        isDense: true,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed:
                              () => setState(
                                () => obscurePassword = !obscurePassword,
                              ),
                        ),
                      ),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Please enter your password'
                                  : null,
                    ),
                    const SizedBox(height: 24),
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
                            label: 'Delete',
                            onPressed: () {
                              if (formKey.currentState?.validate() ?? false) {
                                Navigator.of(context).pop();
                                // TODO: Add delete logic here
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLabel(ThemeData theme, String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          color: theme.textTheme.bodySmall?.color,
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
      ),
    );
  }
}
