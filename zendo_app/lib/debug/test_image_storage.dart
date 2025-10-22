import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';
import '../services/supabase_database_service.dart';
import '../utils/database_checker.dart';

/// Test page để debug vấn đề lưu imageUrl
class TestImageStoragePage extends StatefulWidget {
  const TestImageStoragePage({super.key});

  @override
  State<TestImageStoragePage> createState() => _TestImageStoragePageState();
}

class _TestImageStoragePageState extends State<TestImageStoragePage> {
  final SupabaseDatabaseService _databaseService = SupabaseDatabaseService();
  String _testResults = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Image Storage')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testDatabaseStructure,
              child: const Text('1. Kiểm tra cấu trúc database'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testCreateTaskWithImage,
              child: const Text('2. Test tạo task với imageUrl'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testImageUrlColumn,
              child: const Text('3. Test cột image_url'),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _testResults.isEmpty
                          ? 'Chưa có kết quả test'
                          : _testResults,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _testDatabaseStructure() async {
    setState(() {
      _isLoading = true;
      _testResults = 'Đang kiểm tra cấu trúc database...\n';
    });

    try {
      await DatabaseChecker.checkTasksTableStructure();

      final hasImageColumn = await DatabaseChecker.checkImageUrlColumnExists();

      setState(() {
        _testResults += 'Cột image_url tồn tại: $hasImageColumn\n';
        _testResults += 'Kiểm tra console để xem cấu trúc bảng chi tiết\n';
      });
    } catch (e) {
      setState(() {
        _testResults += 'Lỗi: $e\n';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testCreateTaskWithImage() async {
    setState(() {
      _isLoading = true;
      _testResults += '\nĐang test tạo task với imageUrl...\n';
    });

    try {
      final testTask = Task(
        id: 'test-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Test Task với Image URL',
        description: 'Task test để kiểm tra imageUrl',
        category: TaskCategory.work,
        priority: TaskPriority.medium,
        createdAt: DateTime.now(),
        imageUrl: '/test/path/to/image.jpg', // Test imageUrl
      );

      final createdTask = await _databaseService.createTask(testTask);

      if (createdTask != null) {
        setState(() {
          _testResults += 'Tạo task thành công!\n';
          _testResults += 'ID: ${createdTask.id}\n';
          _testResults += 'Title: ${createdTask.title}\n';
          _testResults += 'ImageUrl: ${createdTask.imageUrl}\n';
        });

        // Xóa test task
        await _deleteTestTask(createdTask.id);
        setState(() {
          _testResults += 'Đã xóa test task\n';
        });
      } else {
        setState(() {
          _testResults += 'Không thể tạo task!\n';
        });
      }
    } catch (e) {
      setState(() {
        _testResults += 'Lỗi khi tạo task: $e\n';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testImageUrlColumn() async {
    setState(() {
      _isLoading = true;
      _testResults += '\nĐang test cột image_url trực tiếp...\n';
    });

    try {
      final success = await DatabaseChecker.testCreateTaskWithImage();
      setState(() {
        _testResults +=
            'Test cột image_url: ${success ? "Thành công" : "Thất bại"}\n';
      });
    } catch (e) {
      setState(() {
        _testResults += 'Lỗi test cột image_url: $e\n';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteTestTask(String taskId) async {
    try {
      await Supabase.instance.client.from('tasks').delete().eq('id', taskId);
    } catch (e) {
      debugPrint('Lỗi xóa test task: $e');
    }
  }
}

