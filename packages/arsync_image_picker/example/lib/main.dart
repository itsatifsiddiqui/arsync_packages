// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:arsync_image_compression/arsync_image_compression.dart';
import 'package:arsync_image_cropper/arsync_image_cropper.dart';
import 'package:arsync_image_picker/arsync_image_picker.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'arsync_image_picker Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const ImagePickerDemo(),
    );
  }
}

// Model to hold image data with metadata
class ImageItem {
  final File file;
  final String originalName;
  final DateTime pickedAt;
  final String source; // 'camera', 'gallery', etc.

  ImageItem({
    required this.file,
    required this.originalName,
    required this.pickedAt,
    required this.source,
  });

  String get fileName => path.basename(file.path);

  String get displayName => originalName.isNotEmpty ? originalName : fileName;

  double get fileSizeInMB => file.lengthSync() / (1024 * 1024);
}

class ImagePickerDemo extends StatefulWidget {
  const ImagePickerDemo({super.key});

  @override
  State<ImagePickerDemo> createState() => _ImagePickerDemoState();
}

class _ImagePickerDemoState extends State<ImagePickerDemo> {
  late ArsyncImagePicker _standardPicker;
  late ArsyncImagePicker _advancedPicker;
  final List<ImageItem> _images = [];
  bool _isLoading = false;
  bool _useAdvancedNaming = false;

  @override
  void initState() {
    super.initState();
    _setupPickers();
  }

  void _setupPickers() {
    // Standard picker with basic naming
    _standardPicker = ArsyncImagePicker(appname: 'Image Picker Demo');
    _standardPicker.addValidator(FileSizeValidator(maxSizeMB: 10.0));
    _standardPicker.addProcessor(FileNameProcessor(newFileName: 'demo_image'));
    _standardPicker.addProcessor(
      ImageCompressionProcessor(targetMaxSizeMB: 2.0),
    );
    _standardPicker.addProcessor(ImageCroppingProcessor());

    // Advanced picker with index-based naming and custom generator
    _advancedPicker = ArsyncImagePicker(appname: 'Advanced Demo');
    _advancedPicker.addValidator(FileSizeValidator(maxSizeMB: 10.0));
    _advancedPicker.addProcessor(
      FileNameProcessor(
        newFileName: 'advanced_image',
        nameGenerator: (String baseName, int index) {
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final sourcePrefix = 'img';
          return '${sourcePrefix}_${baseName}_${index + 1}_$timestamp';
        },
        indexParam: _images.length, // Start index from current count
      ),
    );
    _advancedPicker.addProcessor(
      ImageCompressionProcessor(targetMaxSizeMB: 2.0),
    );
    _advancedPicker.addProcessor(ImageCroppingProcessor());
  }

  ArsyncImagePicker get _currentPicker =>
      _useAdvancedNaming ? _advancedPicker : _standardPicker;

  Future<void> _pickSingleImage() async {
    setState(() => _isLoading = true);

    try {
      final image = await _currentPicker.pickImage(
        context: context,
        onImageSelected: () {
          _showProcessingSnackBar();
        },
      );

      if (image != null) {
        _addImageToList(image, 'Single Pick');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickMultipleImages() async {
    setState(() => _isLoading = true);

    try {
      final images = await _currentPicker.pickImages(
        context: context,
        onImagesSelected: () {
          _showProcessingSnackBar();
        },
      );

      if (images != null) {
        for (int i = 0; i < images.length; i++) {
          _addImageToList(images[i], 'Multiple Pick ${i + 1}');
        }
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() => _isLoading = true);

    try {
      final image = await _currentPicker.pickImageFromGallery(
        context: context,
        onImageSelected: () {
          _showProcessingSnackBar();
        },
      );

      if (image != null) {
        _addImageToList(image, 'Gallery');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickFromCamera() async {
    setState(() => _isLoading = true);

    try {
      final image = await _currentPicker.pickImageFromCamera(
        context: context,
        onImageSelected: () {
          _showProcessingSnackBar();
        },
      );

      if (image != null) {
        _addImageToList(image, 'Camera');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addImageToList(dynamic image, String source) {
    final imageItem = ImageItem(
      file: File(image.path),
      originalName: path.basenameWithoutExtension(image.path),
      pickedAt: DateTime.now(),
      source: source,
    );

    setState(() {
      _images.add(imageItem);
    });

    // Update the advanced picker's index for next pick
    _setupPickers();
  }

  Future<void> _cropIndividualImage(int index) async {
    final imageItem = _images[index];

    setState(() => _isLoading = true);

    try {
      // Create a temporary service just for cropping this individual image
      final croppingService = ArsyncImagePicker(appname: 'Individual Crop');

      // Add only the cropping processor with custom options
      croppingService.addProcessor(
        ImageCroppingProcessor(
          options: CropOptions(
            title: 'Crop ${imageItem.displayName}',
            lockAspectRatio: false,
          ),
        ),
      );

      // Create an XFile from the existing image
      final xFile = XFile(imageItem.file.path);

      // Process the image through the cropping processor
      final croppingProcessor = ImageCroppingProcessor(
        options: CropOptions(
          title: 'Crop ${imageItem.displayName}',
          lockAspectRatio: false,
        ),
      );

      // Check if processing is needed and process the image
      final shouldProcess = await croppingProcessor.shouldProcess(
        xFile,
        false,
        0,
      );

      if (shouldProcess) {
        final croppedResult = await croppingProcessor.process(xFile, false, 0);

        // Replace the image in the list with the cropped version
        final croppedImageItem = ImageItem(
          file: File(croppedResult.path),
          originalName: '${imageItem.originalName}_cropped',
          pickedAt: imageItem.pickedAt,
          source: '${imageItem.source} (Cropped)',
        );

        setState(() {
          _images[index] = croppedImageItem;
        });

        _showSuccessSnackBar('Image cropped successfully!');
      } else {
        _showSuccessSnackBar('No changes made to image');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Crop error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
    // Update pickers after removal
    _setupPickers();
  }

  void _clearImages() {
    setState(() {
      _images.clear();
    });
    _setupPickers();
  }

  void _toggleNamingStrategy() {
    setState(() {
      _useAdvancedNaming = !_useAdvancedNaming;
    });
    _setupPickers();
  }

  void _showProcessingSnackBar() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Processing image...')));
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('arsync_image_picker Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _toggleNamingStrategy,
            icon: Icon(_useAdvancedNaming ? Icons.settings : Icons.abc),
            tooltip: _useAdvancedNaming
                ? 'Switch to Standard Naming'
                : 'Switch to Advanced Naming',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Naming strategy indicator
            _NamingStrategyCard(
              isAdvanced: _useAdvancedNaming,
              imageCount: _images.length,
            ),

            const SizedBox(height: 16),

            // Action buttons
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _pickSingleImage,
                  icon: const Icon(Icons.photo),
                  label: const Text('Pick Single'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _pickMultipleImages,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Pick Multiple'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _pickFromGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Gallery Only'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _pickFromCamera,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera Only'),
                ),
                if (_images.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: _clearImages,
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Loading indicator
            if (_isLoading) const Center(child: CircularProgressIndicator()),

            // Image display with enhanced information
            if (_images.isNotEmpty && !_isLoading)
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 0.8, // Adjusted for text content
                  ),
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return _ImageCard(
                      imageItem: _images[index],
                      index: index,
                      onCrop: () => _cropIndividualImage(index),
                      onRemove: () => _removeImage(index),
                    );
                  },
                ),
              ),

            // Empty state
            if (_images.isEmpty && !_isLoading)
              const Expanded(child: _EmptyState()),
          ],
        ),
      ),
    );
  }
}

// Private widget for naming strategy card
class _NamingStrategyCard extends StatelessWidget {
  const _NamingStrategyCard({
    required this.isAdvanced,
    required this.imageCount,
  });

  final bool isAdvanced;
  final int imageCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isAdvanced ? Colors.blue.shade50 : Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isAdvanced ? Icons.settings : Icons.abc,
                  color: isAdvanced ? Colors.blue : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  isAdvanced ? 'Advanced Naming' : 'Standard Naming',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isAdvanced
                  ? 'Using indexParam (starting from $imageCount) and custom name generator:\n"img_baseName_index_timestamp"'
                  : 'Using static name: "demo_image"',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

// Private widget for individual image cards
class _ImageCard extends StatelessWidget {
  const _ImageCard({
    required this.imageItem,
    required this.index,
    required this.onCrop,
    required this.onRemove,
  });

  final ImageItem imageItem;
  final int index;
  final VoidCallback onCrop;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image with action overlay buttons
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8.0),
                  ),
                  child: Image.file(
                    imageItem.file,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.error, color: Colors.red),
                      );
                    },
                  ),
                ),
                // Action buttons row
                Positioned(
                  top: 4,
                  left: 4,
                  right: 4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Remove button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          onPressed: onRemove,
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          tooltip: 'Remove Image',
                        ),
                      ),
                      // Action buttons
                      Row(
                        children: [
                          // Rename button
                          // Crop button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: IconButton(
                              onPressed: onCrop,
                              icon: const Icon(
                                Icons.crop,
                                color: Colors.white,
                                size: 18,
                              ),
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              tooltip: 'Crop Image',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Image information
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    imageItem.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Source: ${imageItem.source}',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Size: ${imageItem.fileSizeInMB.toStringAsFixed(2)} MB',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                  Text(
                    'File: ${imageItem.fileName}',
                    style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Private widget for rename dialog
class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.currentName});

  final String currentName;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename Image'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'New name',
          hintText: 'Enter new image name',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => Navigator.of(context).pop(_controller.text),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Rename'),
        ),
      ],
    );
  }
}

// Private widget for empty state
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No images selected',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Use the buttons above to pick images',
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 16),
          Text(
            'Features demonstrated:',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            '• Individual image cropping (ImageCroppingProcessor)\n'
            '• Individual image renaming (FileNameProcessor)\n'
            '• Advanced naming with indexParam\n'
            '• Custom name generators\n'
            '• File metadata display\n'
            '• Toggle between naming strategies',
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
