/*
 * Tên: services/task_image_storage_service.dart
 * Tác dụng: Service quản lý upload hình ảnh task lên Supabase Storage bucket "images"
 * Khi nào dùng: Khi người dùng thêm hình ảnh cho task
 */

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

/// Service quản lý upload hình ảnh task lên Supabase Storage
class TaskImageStorageService {
  static final TaskImageStorageService _instance =
      TaskImageStorageService._internal();
  factory TaskImageStorageService() => _instance;
  TaskImageStorageService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _bucketName = 'images';

  /// Upload hình ảnh task lên Supabase Storage
  /// Trả về URL của hình ảnh đã upload
  Future<String?> uploadTaskImage(File imageFile) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('User not authenticated');
        return null;
      }

      // Tạo tên file unique với user ID và timestamp
      final fileExtension = path.extension(imageFile.path).toLowerCase();
      final fileName =
          '${user.id}_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      final filePath = fileName;

      // Đọc file thành bytes
      final bytes = await imageFile.readAsBytes();

      // Upload lên Supabase Storage
      await _supabase.storage
          .from(_bucketName)
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      // Lấy URL công khai bằng getPublicUrl
      final publicUrl = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(filePath);
      
      debugPrint('Task image uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading task image: $e');
      return null;
    }
  }

  /// Upload hình ảnh task từ bytes (cho web)
  Future<String?> uploadTaskImageFromBytes(
      Uint8List bytes, String fileName) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('User not authenticated');
        return null;
      }

      // Tạo tên file unique
      final fileExtension = path.extension(fileName).toLowerCase();
      final uniqueFileName =
          '${user.id}_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      final filePath = uniqueFileName;

      // Upload lên Supabase Storage
      await _supabase.storage
          .from(_bucketName)
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      // Lấy URL công khai bằng getPublicUrl
      final publicUrl = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(filePath);
      
      debugPrint('Task image uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading task image from bytes: $e');
      return null;
    }
  }

  /// Xóa hình ảnh task cũ khi upload hình ảnh mới
  Future<bool> deleteOldTaskImage(String imageUrl) async {
    try {
      // Extract file path từ URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      // Tìm index của bucket name trong path
      final bucketIndex = pathSegments.indexOf(_bucketName);
      if (bucketIndex == -1 || bucketIndex >= pathSegments.length - 1) {
        debugPrint('Invalid image URL format');
        return false;
      }

      // Lấy file path sau bucket name
      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      // Xóa file từ storage
      await _supabase.storage.from(_bucketName).remove([filePath]);

      debugPrint('Old task image deleted successfully: $filePath');
      return true;
    } catch (e) {
      debugPrint('Error deleting old task image: $e');
      return false;
    }
  }

  /// Kiểm tra xem bucket images đã tồn tại chưa
  Future<bool> ensureBucketExists() async {
    try {
      final buckets = await _supabase.storage.listBuckets();
      final bucketExists = buckets.any((bucket) => bucket.name == _bucketName);

      if (!bucketExists) {
        debugPrint(
            'Images bucket does not exist. Please create it in Supabase dashboard.');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error checking bucket existence: $e');
      return false;
    }
  }
}