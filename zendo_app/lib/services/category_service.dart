/*
 * Tên: services/category_service.dart
 * Tác dụng: Service quản lý Categories với Supabase database
 * Khi nào dùng: Cần thao tác CRUD với categories và phân loại tasks
 */

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category.dart';

/// CategoryService Class
/// Tác dụng: Service quản lý Categories với Supabase database
/// Sử dụng khi: Cần thao tác CRUD với categories và phân loại tasks
class CategoryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// getUserCategories Method
  /// Tác dụng: Lấy tất cả categories của user hiện tại (không bao gồm archived)
  /// Sử dụng khi: Cần hiển thị danh sách categories cho user chọn lựa
  Future<List<Category>> getUserCategories() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('categories')
          .select()
          .eq('user_id', user.id)
          .eq('is_archived', false)
          .order('sort_order', ascending: true);

      return (response as List).map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  /// createCategory Method
  /// Tác dụng: Tạo category mới với thông tin đầy đủ
  /// Sử dụng khi: User muốn tạo category mới để phân loại tasks
  Future<Category> createCategory({
    required String name,
    String? description,
    required String icon,
    required String color,
    bool isDefault = false,
    int? sortOrder,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Tính sort_order nếu không được cung cấp
      if (sortOrder == null) {
        final maxOrderResponse = await _supabase
            .from('categories')
            .select('sort_order')
            .eq('user_id', user.id)
            .order('sort_order', ascending: false)
            .limit(1);

        sortOrder = maxOrderResponse.isNotEmpty
            ? (maxOrderResponse.first['sort_order'] as int) + 1
            : 1;
      }

      final categoryData = {
        'user_id': user.id,
        'name': name,
        'description': description,
        'icon': icon,
        'color': color,
        'is_default': isDefault,
        'sort_order': sortOrder,
        'is_archived': false,
      };

      final response = await _supabase
          .from('categories')
          .insert(categoryData)
          .select()
          .single();

      return Category.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  /// Cập nhật category
  Future<Category> updateCategory(
    String categoryId, {
    String? name,
    String? description,
    String? icon,
    String? color,
    bool? isDefault,
    int? sortOrder,
    bool? isArchived,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      if (icon != null) updateData['icon'] = icon;
      if (color != null) updateData['color'] = color;
      if (isDefault != null) updateData['is_default'] = isDefault;
      if (sortOrder != null) updateData['sort_order'] = sortOrder;
      if (isArchived != null) updateData['is_archived'] = isArchived;

      final response = await _supabase
          .from('categories')
          .update(updateData)
          .eq('id', categoryId)
          .eq('user_id', user.id)
          .select()
          .single();

      return Category.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  /// Xóa category (soft delete - archive)
  Future<void> deleteCategory(String categoryId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Kiểm tra xem category có tasks không
      final tasksCount = await _supabase
          .from('tasks')
          .select('id')
          .eq('category_id', categoryId)
          .eq('user_id', user.id)
          .count();

      if (tasksCount.count > 0) {
        throw Exception(
          'Cannot delete category with existing tasks. Please move or delete tasks first.',
        );
      }

      // Soft delete - archive category
      await _supabase
          .from('categories')
          .update({
            'is_archived': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', categoryId)
          .eq('user_id', user.id);
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  /// Tạo default categories cho user mới
  Future<List<Category>> createDefaultCategories() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Kiểm tra xem user đã có categories chưa
      final existingCategories = await _supabase
          .from('categories')
          .select('id')
          .eq('user_id', user.id)
          .limit(1);

      if (existingCategories.isNotEmpty) {
        return getUserCategories(); // Trả về categories hiện có
      }

      // Tạo default categories
      final categoriesData = DefaultCategories.defaults
          .map((category) => {...category, 'user_id': user.id})
          .toList();

      final response = await _supabase
          .from('categories')
          .insert(categoriesData)
          .select();

      return (response as List).map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to create default categories: $e');
    }
  }

  /// Lấy category theo ID
  Future<Category?> getCategoryById(String categoryId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('categories')
          .select()
          .eq('id', categoryId)
          .eq('user_id', user.id)
          .single();

      return Category.fromJson(response);
    } catch (e) {
      return null; // Category not found
    }
  }

  /// Cập nhật thứ tự categories
  Future<void> reorderCategories(List<String> categoryIds) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Cập nhật sort_order cho từng category
      for (int i = 0; i < categoryIds.length; i++) {
        await _supabase
            .from('categories')
            .update({
              'sort_order': i + 1,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', categoryIds[i])
            .eq('user_id', user.id);
      }
    } catch (e) {
      throw Exception('Failed to reorder categories: $e');
    }
  }

  /// Lấy số lượng tasks trong category
  Future<int> getTaskCountInCategory(String categoryId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('tasks')
          .select('id')
          .eq('category_id', categoryId)
          .eq('user_id', user.id)
          .eq('is_archived', false)
          .count();

      return response.count;
    } catch (e) {
      return 0;
    }
  }
}
