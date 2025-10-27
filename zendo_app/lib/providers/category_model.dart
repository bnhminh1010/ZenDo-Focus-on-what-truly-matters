import 'package:flutter/foundation.dart';
import '../models/category.dart' as app_category;
import '../services/category_service.dart';

/// CategoryModel Class
/// Tác dụng: Provider quản lý trạng thái và logic nghiệp vụ của categories trong ứng dụng
/// Sử dụng khi: Cần quản lý danh sách categories, thực hiện CRUD operations với categories
class CategoryModel extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  List<app_category.Category> _categories = [];
  List<app_category.Category> get categories => _categories;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// initialize method
  /// Tác dụng: Khởi tạo CategoryModel và load danh sách categories
  /// Sử dụng khi: Khởi động ứng dụng hoặc khi cần reset toàn bộ dữ liệu categories
  Future<void> initialize() async {
    await loadCategories();
  }

  /// loadCategories method
  /// Tác dụng: Tải danh sách categories từ database, tạo default categories nếu chưa có
  /// Sử dụng khi: Cần refresh dữ liệu categories từ server
  Future<void> loadCategories() async {
    _setLoading(true);
    _clearError();

    try {
      _categories = await _categoryService.getUserCategories();

      // Nếu chưa có categories, tạo default categories
      if (_categories.isEmpty) {
        _categories = await _categoryService.createDefaultCategories();
      }

      debugPrint('CategoryModel: Loaded ${_categories.length} categories');
    } catch (e) {
      _setError('Failed to load categories: $e');
      debugPrint('CategoryModel: Error loading categories - $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Tạo category mới
  Future<bool> createCategory({
    required String name,
    String? description,
    required String icon,
    required String color,
  }) async {
    _clearError();

    try {
      final newCategory = await _categoryService.createCategory(
        name: name,
        description: description,
        icon: icon,
        color: color,
      );

      _categories.add(newCategory);
      _categories.sort(
        (a, b) => (a as app_category.Category).sortOrder.compareTo(
          (b as app_category.Category).sortOrder,
        ),
      );
      notifyListeners();

      debugPrint('CategoryModel: Created category - ${newCategory.name}');
      return true;
    } catch (e) {
      _setError('Failed to create category: $e');
      debugPrint('CategoryModel: Error creating category - $e');
      return false;
    }
  }

  /// Cập nhật category
  Future<bool> updateCategory(
    String categoryId, {
    String? name,
    String? description,
    String? icon,
    String? color,
  }) async {
    _clearError();

    try {
      final updatedCategory = await _categoryService.updateCategory(
        categoryId,
        name: name,
        description: description,
        icon: icon,
        color: color,
      );

      final index = _categories.indexWhere(
        (c) => (c as app_category.Category).id == categoryId,
      );
      if (index != -1) {
        _categories[index] = updatedCategory;
        notifyListeners();
      }

      debugPrint('CategoryModel: Updated category - ${updatedCategory.name}');
      return true;
    } catch (e) {
      _setError('Failed to update category: $e');
      debugPrint('CategoryModel: Error updating category - $e');
      return false;
    }
  }

  /// Xóa category
  Future<bool> deleteCategory(String categoryId) async {
    _clearError();

    try {
      await _categoryService.deleteCategory(categoryId);
      _categories.removeWhere(
        (c) => (c as app_category.Category).id == categoryId,
      );
      notifyListeners();

      debugPrint('CategoryModel: Deleted category - $categoryId');
      return true;
    } catch (e) {
      _setError('Failed to delete category: $e');
      debugPrint('CategoryModel: Error deleting category - $e');
      return false;
    }
  }

  /// Lấy category theo ID
  app_category.Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere(
            (category) => (category as app_category.Category).id == id,
          )
          as app_category.Category;
    } catch (e) {
      return null;
    }
  }

  /// Lấy category theo name
  app_category.Category? getCategoryByName(String name) {
    try {
      return _categories.firstWhere(
        (category) => category.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Tìm kiếm categories
  List<app_category.Category> searchCategories(String query) {
    if (query.isEmpty) return _categories;

    return _categories.where((category) {
      final cat = category as app_category.Category;
      return cat.name.toLowerCase().contains(query.toLowerCase()) ||
          (cat.description?.toLowerCase().contains(query.toLowerCase()) ??
              false);
    }).toList();
  }

  /// Sắp xếp lại categories
  Future<bool> reorderCategories(List<String> categoryIds) async {
    _clearError();

    try {
      // Cập nhật sort order local
      for (int i = 0; i < categoryIds.length; i++) {
        final category =
            _categories.firstWhere(
                  (c) => (c as app_category.Category).id == categoryIds[i],
                )
                as app_category.Category;
        // Tạo category mới với sort order cập nhật
        final updatedCategory = app_category.Category(
          id: category.id,
          userId: category.userId,
          name: category.name,
          description: category.description,
          icon: category.icon,
          color: category.color,
          sortOrder: i,
          createdAt: category.createdAt,
          updatedAt: DateTime.now(),
        );

        final index = _categories.indexWhere(
          (c) => (c as app_category.Category).id == categoryIds[i],
        );
        if (index != -1) {
          _categories[index] = updatedCategory;
        }
      }

      // Cập nhật trên server
      await _categoryService.reorderCategories(categoryIds);

      notifyListeners();
      debugPrint('CategoryModel: Reordered categories');
      return true;
    } catch (e) {
      _setError('Failed to reorder categories: $e');
      debugPrint('CategoryModel: Error reordering categories - $e');
      return false;
    }
  }

  /// Refresh categories từ server
  Future<void> refresh() async {
    await loadCategories();
  }

  /// Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// Dispose
  @override
  void dispose() {
    super.dispose();
  }
}
