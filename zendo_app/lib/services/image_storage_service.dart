/*
 * Tên: services/image_storage_service.dart
 * Tác dụng: Service quản lý lưu trữ hình ảnh cho tasks với copy, save và delete operations
 * Khi nào dùng: Cần xử lý việc lưu trữ và quản lý hình ảnh đính kèm trong tasks
 */

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

/// Service quản lý lưu trữ hình ảnh cho tasks
/// Xử lý việc copy, lưu trữ và quản lý hình ảnh trong app
class ImageStorageService {
  static const String _imagesFolderName = 'task_images';
  static const Uuid _uuid = Uuid();

  /// Lấy thư mục lưu trữ hình ảnh của app
  static Future<Directory> _getImagesDirectory() async {
    // Sử dụng getApplicationSupportDirectory thay vì getApplicationDocumentsDirectory
    // để tránh lỗi với OneDrive và có quyền truy cập tốt hơn
    final appDir = await getApplicationSupportDirectory();
    final imagesDir = Directory(path.join(appDir.path, _imagesFolderName));

    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    return imagesDir;
  }

  /// Lưu hình ảnh từ file tạm thời vào thư mục app
  /// Trả về đường dẫn file mới hoặc null nếu có lỗi
  static Future<String?> saveTaskImage(File tempImageFile) async {
    try {
      if (!await tempImageFile.exists()) {
        debugPrint('ImageStorageService: Temp image file does not exist');
        return null;
      }

      final imagesDir = await _getImagesDirectory();
      final fileExtension = path.extension(tempImageFile.path);
      final newFileName = '${_uuid.v4()}$fileExtension';
      final newFilePath = path.join(imagesDir.path, newFileName);

      // Copy file từ thư mục tạm vào thư mục app
      final newFile = await tempImageFile.copy(newFilePath);

      debugPrint('ImageStorageService: Image saved to ${newFile.path}');
      return newFile.path;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  /// Xóa hình ảnh khỏi thư mục app
  static Future<bool> deleteTaskImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('ImageStorageService: Image deleted: $imagePath');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }

  /// Kiểm tra xem file hình ảnh có tồn tại không
  static Future<bool> imageExists(String imagePath) async {
    try {
      final file = File(imagePath);
      return await file.exists();
    } catch (e) {
      debugPrint('Error downloading image: $e');
      return false;
    }
  }

  /// Lấy kích thước file hình ảnh (bytes)
  static Future<int?> getImageSize(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        return await file.length();
      }
      return null;
    } catch (e) {
      debugPrint('ImageStorageService: Error getting image size: $e');
      return null;
    }
  }

  /// Dọn dẹp các file hình ảnh không sử dụng
  /// (Có thể gọi định kỳ để xóa các file không còn được reference)
  static Future<void> cleanupUnusedImages(List<String> usedImagePaths) async {
    try {
      final imagesDir = await _getImagesDirectory();
      final files = await imagesDir.list().toList();

      for (final file in files) {
        if (file is File) {
          final filePath = file.path;
          if (!usedImagePaths.contains(filePath)) {
            await file.delete();
            debugPrint(
              'ImageStorageService: Cleaned up unused image: $filePath',
            );
          }
        }
      }
    } catch (e) {
      debugPrint('ImageStorageService: Error during cleanup: $e');
    }
  }
}
