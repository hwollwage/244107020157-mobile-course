import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quality_assurance/main.dart';
import 'package:quality_assurance/task_page.dart';

Widget _buildApp() => const MaterialApp(home: TaskPage());

void main() {
  group('TaskPage – initial display', () {
    testWidgets('shows the Task list title in the app bar', (tester) async {
      await tester.pumpWidget(_buildApp());
      expect(find.text('Task list'), findsOneWidget);
    });

    testWidgets('shows the task-title text field', (tester) async {
      await tester.pumpWidget(_buildApp());
      expect(find.byKey(const Key('task-title-field')), findsOneWidget);
    });

    testWidgets('shows the Save task button', (tester) async {
      await tester.pumpWidget(_buildApp());
      expect(find.byKey(const Key('save-task-button')), findsOneWidget);
    });

    testWidgets('shows an empty-state message when there are no tasks',
        (tester) async {
      await tester.pumpWidget(_buildApp());
      expect(find.byKey(const Key('empty-message')), findsOneWidget);
      expect(find.text('No tasks yet.'), findsOneWidget);
    });
  });

  group('TaskPage – invalid input', () {
    testWidgets('shows an error when saving with an empty title',
        (tester) async {
      await tester.pumpWidget(_buildApp());

      await tester.tap(find.byKey(const Key('save-task-button')));
      await tester.pump();

      expect(find.text('Title cannot be empty'), findsOneWidget);
    });

    testWidgets('shows an error when saving a whitespace-only title',
        (tester) async {
      await tester.pumpWidget(_buildApp());

      await tester.enterText(
          find.byKey(const Key('task-title-field')), '   ');
      await tester.tap(find.byKey(const Key('save-task-button')));
      await tester.pump();

      expect(find.text('Title cannot be empty'), findsOneWidget);
    });
  });

  group('TaskPage – successful user action', () {
    testWidgets('adds a task and shows it in the list', (tester) async {
      await tester.pumpWidget(_buildApp());

      await tester.enterText(
          find.byKey(const Key('task-title-field')), 'Read the material');
      await tester.tap(find.byKey(const Key('save-task-button')));
      await tester.pumpAndSettle();

      expect(find.text('Read the material'), findsOneWidget);
      expect(find.byKey(const Key('empty-message')), findsNothing);
    });

    testWidgets('clears the text field after saving', (tester) async {
      await tester.pumpWidget(_buildApp());

      await tester.enterText(
          find.byKey(const Key('task-title-field')), 'Some task');
      await tester.tap(find.byKey(const Key('save-task-button')));
      await tester.pumpAndSettle();

      final field =
          tester.widget<TextField>(find.byKey(const Key('task-title-field')));
      expect(field.controller!.text, '');
    });

    testWidgets('removes the error message after a valid submission',
        (tester) async {
      await tester.pumpWidget(_buildApp());

      // Trigger error first.
      await tester.tap(find.byKey(const Key('save-task-button')));
      await tester.pump();
      expect(find.text('Title cannot be empty'), findsOneWidget);

      // Now submit a valid title.
      await tester.enterText(
          find.byKey(const Key('task-title-field')), 'Valid task');
      await tester.tap(find.byKey(const Key('save-task-button')));
      await tester.pumpAndSettle();

      expect(find.text('Title cannot be empty'), findsNothing);
    });

    testWidgets('can add multiple tasks', (tester) async {
      await tester.pumpWidget(_buildApp());

      for (final title in ['Task 1', 'Task 2', 'Task 3']) {
        await tester.enterText(
            find.byKey(const Key('task-title-field')), title);
        await tester.tap(find.byKey(const Key('save-task-button')));
        await tester.pumpAndSettle();
      }

      expect(find.text('Task 1'), findsOneWidget);
      expect(find.text('Task 2'), findsOneWidget);
      expect(find.text('Task 3'), findsOneWidget);
    });
  });

  // Keep the original smoke test working with the new app entry point.
  testWidgets('MyApp renders without error', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(TaskPage), findsOneWidget);
  });
}
