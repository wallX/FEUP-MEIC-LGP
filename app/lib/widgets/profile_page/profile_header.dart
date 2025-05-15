import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/user_provider.dart';
import 'package:app/provider/theme_provider.dart';
import 'package:app/utils/profile_image_utils.dart';
import 'package:app/widgets/profile_page/image_options_dialog.dart';

class ProfileHeader extends StatelessWidget {
  final File? profileImage;
  final Function(File?) onImageSelected;

  const ProfileHeader({
    super.key,
    required this.profileImage,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final user = context.read<UserProvider>().user!;
    final theme = context.watch<ThemeProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(42),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image:
                        profileImage != null
                            ? FileImage(profileImage!)
                            : const AssetImage('lib/assets/avatar.png')
                                as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Positioned(
            //   bottom: 0,
            //   right: 0,
            //   child: CircleAvatar(
            //     radius: 16,
            //     backgroundColor: theme.primaryColor,
            //     child: IconButton(
            //       icon: const Icon(Icons.edit, size: 16, color: Colors.white),
            //       onPressed: () {
            //         if (profileImage == null) {
            //           pickAndSaveProfileImage(
            //             userEmail: user.email,
            //             onImageSelected: onImageSelected,
            //           );
            //         } else {
            //           showDialog(
            //             context: context,
            //             builder:
            //                 (_) => ImageOptionsDialog(
            //                   profileImage: profileImage,
            //                   onImageSelected: onImageSelected,
            //                   userEmail: user.email,
            //                 ),
            //           );
            //         }
            //       },
            //     ),
            //   ),
            // ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          user.name,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: theme.textColor,
          ),
        ),
        Text(
          user.email,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }
}
