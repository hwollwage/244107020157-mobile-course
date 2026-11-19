import 'package:flutter_test/flutter_test.dart';
import 'package:quality_assurance/task_repository.dart';

void main() {
  group('TaskService', () {
    // --- success path ---
    test('returns data from the repository', () async {
      final service = TaskService(
        FakeTaskRepository(tasks: ['Read the material']),
      );

      expect(await service.loadTasks(), ['Read the material']);
    });

    test('returns an empty list when the repository has no tasks', () async {
      final service = TaskService(FakeTaskRepository());

      expect(await service.loadTasks(), isEmpty);
    });

    test('returns multiple tasks in order', () async {
      final service = TaskService(
        FakeTaskRepository(tasks: ['Task A', 'Task B', 'Task C']),
      );

      expect(await service.loadTasks(), ['Task A', 'Task B', 'Task C']);
    });

    // --- failure path ---
    test('propagates an exception from the repository', () async {
      final service = TaskService(
        FakeTaskRepository(error: Exception('network error')),
      );

      expect(service.loadTasks(), throwsException);
    });
  });
}
