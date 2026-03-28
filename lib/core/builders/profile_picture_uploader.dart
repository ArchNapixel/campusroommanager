import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

/// Widget for uploading and displaying profile picture
class ProfilePictureUploader extends StatefulWidget {
  final String userId;
  final String? currentImageUrl;
  final Function(String) onUploadComplete;
  final VoidCallback? onUploadStart;

  const ProfilePictureUploader({
    Key? key,
    required this.userId,
    this.currentImageUrl,
    required this.onUploadComplete,
    this.onUploadStart,
  }) : super(key: key);

  @override
  State<ProfilePictureUploader> createState() => _ProfilePictureUploaderState();
}

class _ProfilePictureUploaderState extends State<ProfilePictureUploader> {
  bool _isLoading = false;
  String? _errorMessage;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  /// Pick an image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _errorMessage = null;
        });

        // Show upload dialog
        _showUploadConfirmation();
      }
    } catch (e) {
      print('❌ [ProfilePictureUploader] Error picking image: $e');
      setState(() => _errorMessage = 'Failed to pick image');
    }
  }

  /// Show confirmation dialog before upload
  void _showUploadConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Profile Picture?'),
        content: Container(
          constraints: const BoxConstraints(maxHeight: 300),
          child: _selectedImage != null
              ? Image.file(_selectedImage!, fit: BoxFit.cover)
              : const SizedBox.shrink(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _selectedImage = null);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _selectedImage != null ? _uploadImage : null,
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  /// Upload the selected image to Supabase Storage
  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    widget.onUploadStart?.call();

    try {
      print('📸 [ProfilePictureUploader] Starting upload for user: ${widget.userId}');

      // Delete previous pictures
      await StorageService.deleteProfilePicture(widget.userId);

      // Upload new picture
      final imageUrl = await StorageService.uploadProfilePicture(
        widget.userId,
        _selectedImage!,
      );

      print('✅ [ProfilePictureUploader] Upload successful: $imageUrl');

      if (mounted) {
        Navigator.pop(context); // Close dialog
        setState(() {
          _isLoading = false;
          _selectedImage = null;
        });
        widget.onUploadComplete(imageUrl);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profile picture updated successfully!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ [ProfilePictureUploader] Upload failed: $e');
      if (mounted) {
        Navigator.pop(context); // Close dialog
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Upload failed: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Profile Picture Display
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.maintenance,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.maintenance.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.maintenance,
                    ),
                  ),
                )
              : ClipOval(
                  child: widget.currentImageUrl != null
                      ? Image.network(
                          widget.currentImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.deepNavy,
                              child: const Icon(
                                Icons.person,
                                size: 60,
                                color: AppColors.mutedText,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: AppColors.deepNavy,
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: AppColors.mutedText,
                          ),
                        ),
                ),
        ),
        const SizedBox(height: 16),

        // Upload Buttons
        if (!_isLoading)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.image),
                label: const Text('Gallery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.maintenance,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.maintenance,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),

        // Error Message
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                border: Border.all(color: AppColors.error),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
