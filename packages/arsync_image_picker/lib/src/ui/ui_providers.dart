import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/config.dart';

typedef ChooseFromPhotos =
    Future<List<XFile>?> Function(
      BuildContext context,
      bool allowMultiples,
      String appname,
    );

typedef TakePhoto =
    Future<XFile?> Function(BuildContext context, String appname);

abstract class ImagePickerUIProvider {
  Future<List<XFile>?> showImagePickerUI({
    required BuildContext context,
    required bool allowMultiple,
    required ImagePickerUIConfig config,
    Function? onRemove,
    required String appname,
    required ChooseFromPhotos chooseFromPhotos,
    required TakePhoto takePhoto,
  });
}

/// A WhatsApp-style UI provider for image picker
class DefaultImagePickerUI implements ImagePickerUIProvider {
  @override
  Future<List<XFile>?> showImagePickerUI({
    required BuildContext context,
    required bool allowMultiple,
    required ImagePickerUIConfig config,
    Function? onRemove,
    required String appname,
    required ChooseFromPhotos chooseFromPhotos,
    required TakePhoto takePhoto,
  }) async {
    return showModalBottomSheet<List<XFile>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return _DefaultSheet(
          appname: appname,
          title: config.title,
          allowMultiple: allowMultiple,
          galleryButtonText: config.galleryButtonText,
          cameraButtonText: config.cameraButtonText,
          removeButtonText: config.removeButtonText,
          cancelButtonText: config.cancelButtonText,
          onRemove: onRemove,
          chooseFromPhotos: chooseFromPhotos,
          takePhoto: takePhoto,
        );
      },
    );
  }
}

class _DefaultSheet extends StatefulWidget {
  final String title;
  final bool allowMultiple;
  final String galleryButtonText;
  final String cameraButtonText;
  final String removeButtonText;
  final String cancelButtonText;
  final Function? onRemove;
  final ChooseFromPhotos chooseFromPhotos;
  final TakePhoto takePhoto;
  final String appname;

  const _DefaultSheet({
    required this.title,
    required this.allowMultiple,
    required this.galleryButtonText,
    required this.cameraButtonText,
    required this.removeButtonText,
    required this.cancelButtonText,
    this.onRemove,
    required this.chooseFromPhotos,
    required this.takePhoto,
    required this.appname,
  });

  @override
  State<_DefaultSheet> createState() => _DefaultSheetState();
}

class _DefaultSheetState extends State<_DefaultSheet> {
  bool isGalleryLoading = false;
  bool isCameraLoading = false;

  bool get isLoading => isGalleryLoading || isCameraLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate the adaptive colors
    final adaptive12 = isDark
        ? Colors.white.withValues(alpha: .12)
        : Colors.black.withValues(alpha: .12);
    final adaptive26 = isDark
        ? Colors.white.withValues(alpha: .12)
        : Colors.black.withValues(alpha: .12);

    return Material(
      color: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 56,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: adaptive26,
              ),
            ),

            // Title
            if (widget.title.isNotEmpty) ...[
              const SizedBox(height: 12),
              Center(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Divider(height: 0, color: adaptive12),
            ],

            const SizedBox(height: 16),

            // Options card
            Card(
              elevation: 0,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(width: 0.5, color: adaptive12),
              ),
              child: Column(
                children: [
                  // Choose from photos
                  ListTile(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    horizontalTitleGap: 0,
                    onTap: () async {
                      try {
                        if (isLoading) return;
                        setState(() => isGalleryLoading = true);
                        final photos = await widget.chooseFromPhotos(
                          context,
                          widget.allowMultiple,
                          widget.appname,
                        );
                        if (photos == null) return;
                        if (!context.mounted) return;
                        Navigator.pop(context, photos);
                      } catch (e) {
                        debugPrint('Error picking image: $e');
                      } finally {
                        if (mounted) {
                          setState(() => isGalleryLoading = false);
                        }
                      }
                    },
                    title: Text(widget.galleryButtonText),
                    leading: const Icon(Icons.photo_rounded),
                    trailing: isGalleryLoading
                        ? const CupertinoActivityIndicator()
                        : const Icon(Icons.chevron_right),
                  ),

                  Divider(height: 0, color: adaptive12),

                  // Take photo
                  ListTile(
                    shape: widget.onRemove != null
                        ? null
                        : const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(12),
                            ),
                          ),
                    horizontalTitleGap: 0,
                    onTap: () async {
                      try {
                        if (isLoading) return;
                        setState(() => isCameraLoading = true);
                        final photo = await widget.takePhoto(
                          context,
                          widget.appname,
                        );
                        if (photo == null) return;
                        if (!context.mounted) return;
                        Navigator.pop(context, [photo]);
                      } catch (e) {
                        debugPrint('Error taking photo: $e');
                      } finally {
                        if (mounted) {
                          setState(() => isCameraLoading = false);
                        }
                      }
                    },
                    title: Text(widget.cameraButtonText),
                    leading: const Icon(Icons.photo_camera_rounded),
                    trailing: isCameraLoading
                        ? const CupertinoActivityIndicator()
                        : const Icon(Icons.chevron_right),
                  ),

                  // Remove option if provided
                  if (widget.onRemove != null) ...[
                    Divider(height: 0, color: adaptive12),

                    ListTile(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(12),
                        ),
                      ),
                      horizontalTitleGap: 0,
                      onTap: () {
                        if (isLoading) return;
                        Navigator.pop(context);
                        widget.onRemove?.call();
                      },
                      title: Text(
                        widget.removeButtonText,
                        style: const TextStyle(color: Colors.red),
                      ),
                      leading: const Icon(
                        Icons.remove_circle_outline_rounded,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Cancel button
            Card(
              elevation: 0,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(width: 0.5, color: adaptive12),
              ),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () => Navigator.pop(context, null),
                title: Text(
                  widget.cancelButtonText,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: const Icon(Icons.cancel_outlined, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A modern Cupertino-style UI provider for image picker
class CupertinoImagePickerUI implements ImagePickerUIProvider {
  @override
  Future<List<XFile>?> showImagePickerUI({
    required BuildContext context,
    required bool allowMultiple,
    required ImagePickerUIConfig config,
    Function? onRemove,
    required String appname,
    required ChooseFromPhotos chooseFromPhotos,
    required TakePhoto takePhoto,
  }) async {
    return showCupertinoModalPopup<List<XFile>>(
      context: context,
      barrierDismissible: true,
      builder: (context) => CupertinoActionSheet(
        title: Text(
          config.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: CupertinoColors.secondaryLabel,
          ),
        ),
        actions: [
          // Gallery option
          CupertinoActionSheetAction(
            onPressed: () async {
              final photos = await chooseFromPhotos(
                context,
                allowMultiple,
                appname,
              );
              if (photos == null) return;
              if (!context.mounted) return;
              Navigator.pop(context, photos);
            },
            child: Text(config.galleryButtonText),
          ),

          // Camera option
          CupertinoActionSheetAction(
            onPressed: () async {
              final photo = await takePhoto(context, appname);
              if (photo == null) return;
              if (!context.mounted) return;
              Navigator.pop(context, [photo]);
            },
            child: Text(config.cameraButtonText),
          ),

          // Remove option (if provided)
          if (onRemove != null)
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context);
                onRemove();
              },
              child: Text(config.removeButtonText),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          isDefaultAction: true,
          child: Text(
            config.cancelButtonText,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
