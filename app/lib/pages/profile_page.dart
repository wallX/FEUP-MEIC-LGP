import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/user_provider.dart';
import 'package:app/provider/theme_provider.dart';
import 'package:app/widgets/change_theme_button.dart';
import 'package:app/widgets/profile_page/image_options_dialog.dart';
import 'package:app/widgets/profile_page/logout_confirmation_dialog.dart';
import 'package:app/widgets/profile_page/delete_account_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userEmail = context.read<UserProvider>().user?.email ?? '';

    String? storedPath = prefs.getString('$userEmail-profileImagePath');

    if (storedPath != null) {
      setState(() {
        _profileImage = File(storedPath);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return AppBar(
              backgroundColor: themeProvider.backgroundColor,
              iconTheme: IconThemeData(color: themeProvider.textColor),
            );
          },
        ),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.user;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _profilePicture(),
                const SizedBox(height: 12),
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, _) {
                    return Text(
                      user?.name ?? 'N/A',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textColor,
                      ),
                    );
                  },
                ),
                Text(
                  '${user?.email ?? 'N/A'}',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16),
                  title: const Text('Theme', style: TextStyle(fontSize: 16)),
                  trailing: const ChangeThemeButton(),
                ),
                const Divider(),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16),
                  title: const Text('Log out', style: TextStyle(fontSize: 16)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const LogoutConfirmationDialog();
                      },
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16),
                  title: const Text('Delete account', style: TextStyle(fontSize: 16)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const DeleteAccountDialog();
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _profilePicture() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Text(
                "Profile",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textColor,
                ),
              ),
            ),
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(42),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: _profileImage != null
                            ? FileImage(_profileImage!)
                            : const AssetImage('lib/assets/avatar.png') as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFFF16912),
                    child: IconButton(
                      icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ImageOptionsDialog(
                              profileImage: _profileImage,
                              onImageSelected: (newImage) {
                                setState(() {
                                  _profileImage = newImage;
                                });
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
