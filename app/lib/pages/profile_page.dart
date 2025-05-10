import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/provider/user_provider.dart';
import 'package:app/widgets/change_theme_button.dart';
import 'package:app/widgets/profile_page/profile_header.dart';
import 'package:app/widgets/profile_page/logout_confirmation_dialog.dart';
import 'package:app/widgets/profile_page/delete_account_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImage;
  String? _loadedEmail;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.read<UserProvider>().user;
    if (user != null && user.email != _loadedEmail) {
      _loadedEmail = user.email;
      _restoreProfileImage(user.email);
    }
  }

  Future<void> _restoreProfileImage(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final storedPath = prefs.getString('$email-profileImagePath');

    if (storedPath != null && File(storedPath).existsSync()) {
      setState(() {
        _profileImage = File(storedPath);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                ProfileHeader(
                  profileImage: _profileImage,
                  onImageSelected: (newImage) {
                    setState(() {
                      _profileImage = newImage;
                    });
                  },
                ),
                const SizedBox(height: 40),
                _buildSettingsTile(
                  title: 'Theme',
                  trailing: const ChangeThemeButton(),
                ),
                const Divider(),
                _buildSettingsTile(
                  title: 'Log out',
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showDialog(const LogoutConfirmationDialog()),
                ),
                // const Divider(),
                // _buildSettingsTile(
                //   title: 'Delete account',
                //   trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                //   onTap: () => _showDialog(const DeleteAccountDialog()),
                // ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showDialog(Widget dialog) {
    showDialog(context: context, builder: (_) => dialog);
  }
}
