// lib/screens/profile/widgets/profile_header.dart
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../views/profile_view_model.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileViewModel vm;

  const ProfileHeader({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGuest = !vm.isAuthenticated;

    final userName = vm.isAuthenticated ? vm.displayName : 'Гость';
    final subtitle = vm.isAuthenticated
        ? 'Местный исследователь'
        : 'Войдите, чтобы сохранять избранное и историю';

    final avatarUrl = vm.avatar;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (isGuest) {
              context.push('/login');
            } else {
              _openEditSheet(context);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // аватар
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor:
                          theme.colorScheme.primary.withOpacity(0.12),
                      backgroundImage: avatarUrl.isNotEmpty
                          ? CachedNetworkImageProvider(
                              avatarUrl,
                              headers: const {'User-Agent': 'Mozilla/5.0'},
                            )
                          : null,
                      child: avatarUrl.isEmpty
                          ? Icon(
                              Icons.person,
                              size: 32,
                              color: theme.colorScheme.primary,
                            )
                          : null,
                    ),
                    if (!isGuest)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),

                // текстовая часть
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withOpacity(0.8),
                        ),
                      ),

                      if (isGuest) ...[
                        const SizedBox(height: 8),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () => context.push('/login'),
                          child: Text(
                            'Войти или зарегистрироваться',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () => _openEditSheet(context),
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Редактировать профиль'),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────── bottom sheet редактирования ─────────

  void _openEditSheet(BuildContext context) {
    if (!vm.isAuthenticated) {
      context.push('/login');
      return;
    }

    final theme = Theme.of(context);
    final user = vm.user;
    final nameController = TextEditingController(
      text: user?.profile.fullName ?? '',
    );

    File? avatarFile;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        bool isSaving = false;

        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: 16 + MediaQuery.of(sheetCtx).viewInsets.bottom,
            ),
            child: StatefulBuilder(
              builder: (sheetCtx, setSheetState) {
                Future<void> pickAvatar() async {
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1024,
                    maxHeight: 1024,
                    imageQuality: 85,
                  );
                  if (picked != null) {
                    setSheetState(() {
                      avatarFile = File(picked.path);
                    });
                  }
                }

                Future<void> save() async {
                  if (isSaving) return;
                  setSheetState(() => isSaving = true);

                  final fullName = nameController.text.trim();

                  final ok = await vm.updateProfile(
                    fullName: fullName.isEmpty ? null : fullName,
                    avatarFile: avatarFile,
                  );

                  if (!sheetCtx.mounted) return;
                  setSheetState(() => isSaving = false);

                  if (ok) {
                    Navigator.of(sheetCtx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Профиль обновлён')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Не удалось обновить профиль'),
                      ),
                    );
                  }
                }

                Widget buildAvatar() {
                  final avatarUrl = vm.avatar;

                  Widget inner;
                  if (avatarFile != null) {
                    inner = ClipOval(
                      child: Image.file(
                        avatarFile!,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      ),
                    );
                  } else if (avatarUrl.isNotEmpty) {
                    inner = CircleAvatar(
                      radius: 36,
                      backgroundImage: CachedNetworkImageProvider(
                        avatarUrl,
                        headers: const {'User-Agent': 'Mozilla/5.0'},
                      ),
                    );
                  } else {
                    inner = CircleAvatar(
                      radius: 36,
                      backgroundColor:
                          theme.colorScheme.primary.withOpacity(0.12),
                      child: Icon(
                        Icons.person,
                        size: 32,
                        color: theme.colorScheme.primary,
                      ),
                    );
                  }

                  return Stack(
                    children: [
                      inner,
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Material(
                          color: theme.colorScheme.primary,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: pickAvatar,
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    Text(
                      'Редактировать профиль',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        buildAvatar(),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Обновите имя и фото профиля, чтобы вас было легче узнать.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Имя и фамилия',
                        hintText: 'Как к вам обращаться',
                      ),
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(sheetCtx).pop(),
                            child: const Text('Отмена'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isSaving ? null : save,
                            child: isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Сохранить'),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
