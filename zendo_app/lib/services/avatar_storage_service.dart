/*
 * Tên: services/avatar_storage_service.dart
 * Tác dụng: Service quản lý upload và lưu trữ avatar của người dùng lên Supabase Storage
 * Khi nào dùng: Khi người dùng cập nhật avatar trong profile page
 */

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

/// Service quản lý upload avatar lên Supabase Storage
class AvatarStorageService {
  static final AvatarStorageService _instance = AvatarStorageService._internal();
  factory AvatarStorageService() => _instance;
  AvatarStorageService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _bucketName = 'avatars';

  /// Upload avatar lên Supabase Storage
  /// Trả về URL của avatar đã upload
  Future<String?> uploadAvatar(File imageFile) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('User not authenticated');
        return null;
      }

      // Tạo tên file unique với user ID và timestamp
      final fileExtension = path.extension(imageFile.path).toLowerCase();
      final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      final filePath = 'avatars/$fileName';

      // Đọc file thành bytes
      final bytes = await imageFile.readAsBytes();

      // Upload lên Supabase Storage
      await _supabase.storage
          .from(_bucketName)
          .uploadBinary(filePath, bytes, fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: true,
          ));

      // Lấy public URL
      final publicUrl = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(filePath);

      debugPrint('Avatar uploaded successfully: $publicUrl');
      return publicUrl;

    } catch (e) {
      debugPrint('Error uploading avatar: $e');
      return null;
    }
  }

  /// Upload avatar từ bytes (cho web)
  Future<String?> uploadAvatarFromBytes(Uint8List bytes, String fileName) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('User not authenticated');
        return null;
      }

      // Tạo tên file unique
      final fileExtension = path.extension(fileName).toLowerCase();
      final uniqueFileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      final filePath = 'avatars/$uniqueFileName';

      // Upload lên Supabase Storage
      await _supabase.storage
          .from(_bucketName)
          .uploadBinary(filePath, bytes, fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: true,
          ));

      // Lấy public URL
      final publicUrl = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(filePath);

      debugPrint('Avatar uploaded successfully: $publicUrl');
      return publicUrl;

    } catch (e) {
      debugPrint('Error uploading avatar from bytes: $e');
      return null;
    }
  }

  /// Xóa avatar cũ khi upload avatar mới
  Future<bool> deleteOldAvatar(String avatarUrl) async {
    try {
      // Extract file path từ URL
      final uri = Uri.parse(avatarUrl);
      final pathSegments = uri.pathSegments;
      
      // Tìm index của bucket name trong path
      final bucketIndex = pathSegments.indexOf(_bucketName);
      if (bucketIndex == -1 || bucketIndex >= pathSegments.length - 1) {
        debugPrint('Invalid avatar URL format');
        return false;
      }

      // Lấy file path sau bucket name
      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
      
      // Xóa file từ storage
      await _supabase.storage
          .from(_bucketName)
          .remove([filePath]);

      debugPrint('Old avatar deleted successfully: $filePath');
      return true;

    } catch (e) {
      debugPrint('Error deleting old avatar: $e');
      return false;
    }
  }

  /// Kiểm tra xem bucket avatars đã tồn tại chưa
  Future<bool> ensureBucketExists() async {
    try {
      final buckets = await _supabase.storage.listBuckets();
      final bucketExists = buckets.any((bucket) => bucket.name == _bucketName);
      
      if (!bucketExists) {
        debugPrint('Avatars bucket does not exist. Please create it in Supabase dashboard.');
        return false;
      }
      
      return true;
    } catch (e) {
      debugPrint('Error checking bucket existence: $e');
      return false;
    }
  }
}