import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Model cho Category
class Category {
  final String id;
  final String name;
  final String icon;
  final String color;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: map['icon'] as String,
      color: map['color'] as String,
      userId: map['user_id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? icon,
    String? color,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Service chuyên xử lý các operations liên quan đến categories
/// Bao gồm CRUD operations và realtime updates
class CategoryService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  List<Category> _categories = [];
  List<Category> get categories => _categories;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;

  // Getter để lấy user ID hiện tại
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Kiểm tra user đã đăng nhập chưa
  bool get isUserAuthenticated => _currentUserId != null;

  /// Khởi tạo service và load categories
  Future<void> initialize() async {
    if (!isUserAuthenticated) {
      debugPrint('CategoryService: User not authenticated');
      return;
    }
    
    await loadCategories();
    _setupRealtimeSubscription();
  }

  /// Load tất cả categories của user
  Future<void> loadCategories() async {
    if (!isUserAuthenticated) {
      _error = 'User not authenticated';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('categories')
          .select('*')
          .eq('user_id', _currentUserId!)
          .order('created_at', ascending: true);

      _categories = (response as List)
          .map((categoryData) => Category.fromMap(categoryData))
          .toList();
      
      debugPrint('CategoryService: Loaded ${_categories.length} categories');
    } catch (e) {
      _error = 'Error loading categories: $e';
      debugPrint('CategoryService: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tạo category mới
  Future<bool> createCategory({
    required String name,
    required String icon,
    required String color,
  }) async {
    if (!isUserAuthenticated) {
      _error = 'User not authenticated';
      notifyListeners();
      return false;
    }

    try {
      final response = await _supabase
          .from('categories')
          .insert({
            'name': name,
            'icon': icon,
            'color': color,
            'user_id': _currentUserId!,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      final newCategory = Category.fromMap(response);
      _categories.add(newCategory);
      
      debugPrint('CategoryService: Category created successfully - $name');
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error creating category: $e';
      debugPrint('CategoryService: $_error');
      notifyListeners();
      return false;
    }
  }

  /// Cập nhật category
  Future<bool> updateCategory(Category category) async {
    if (!isUserAuthenticated) {
      _error = 'User not authenticated';
      notifyListeners();
      return false;
    }

    try {
      await _supabase
          .from('categories')
          .update({
            'name': category.name,
            'icon': category.icon,
            'color': category.color,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', category.id)
          .eq('user_id', _currentUserId!);

      // Cập nhật trong local list
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category.copyWith(updatedAt: DateTime.now());
        notifyListeners();
      }

      debugPrint('CategoryService: Category updated successfully - ${category.name}');
      return true;
    } catch (e) {
      _error = 'Error updating category: $e';
      debugPrint('CategoryService: $_error');
      notifyListeners();
      return false;
    }
  }

  /// Xóa category
  Future<bool> deleteCategory(String categoryId) async {
    if (!isUserAuthenticated) {
      _error = 'User not authenticated';
      notifyListeners();
      return false;
    }

    try {
      await _supabase
          .from('categories')
          .delete()
          .eq('id', categoryId)
          .eq('user_id', _currentUserId!);

      // Xóa khỏi local list
      _categories.removeWhere((category) => category.id == categoryId);
      
      debugPrint('CategoryService: Category deleted successfully');
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error deleting category: $e';
      debugPrint('CategoryService: $_error');
      notifyListeners();
      return false;
    }
  }

  /// Lấy category theo ID
  Category? getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere((category) => category.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  /// Tìm kiếm categories
  List<Category> searchCategories(String query) {
    if (query.isEmpty) return _categories;
    
    final lowercaseQuery = query.toLowerCase();
    return _categories.where((category) {
      return category.name.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Lấy categories mặc định để tạo khi user đăng ký
  static List<Map<String, String>> getDefaultCategories() {
    return [
      {
        'name': 'Công việc',
        'icon': 'work',
        'color': '#2196F3',
      },
      {
        'name': 'Cá nhân',
        'icon': 'person',
        'color': '#4CAF50',
      },
      {
        'name': 'Học tập',
        'icon': 'school',
        'color': '#FF9800',
      },
      {
        'name': 'Sức khỏe',
        'icon': 'fitness_center',
        'color': '#E91E63',
      },
      {
        'name': 'Gia đình',
        'icon': 'family_restroom',
        'color': '#9C27B0',
      },
    ];
  }

  /// Tạo categories mặc định cho user mới
  Future<void> createDefaultCategories() async {
    if (!isUserAuthenticated) return;

    final defaultCategories = getDefaultCategories();
    
    for (final categoryData in defaultCategories) {
      await createCategory(
        name: categoryData['name']!,
        icon: categoryData['icon']!,
        color: categoryData['color']!,
      );
    }
  }

  /// Setup realtime subscription để sync categories
  void _setupRealtimeSubscription() {
    if (!isUserAuthenticated) return;

    _supabase
        .channel('categories_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'categories',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: _currentUserId!,
          ),
          callback: (payload) {
            debugPrint('CategoryService: Realtime update received');
            loadCategories(); // Reload categories khi có thay đổi
          },
        )
        .subscribe();
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _supabase.removeAllChannels();
    super.dispose();
  }
}