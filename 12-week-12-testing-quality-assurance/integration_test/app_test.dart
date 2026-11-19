import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:quality_assurance/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Integration – task list flow', () {
    testWidgets('a user can add a task and see it in the list', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('task-title-field')),
        'Read the material',
      );
      await tester.tap(find.byKey(const Key('save-task-button')));
      await tester.pumpAndSettle();

      expect(find.text('Read the material'), findsOneWidget);
      expect(find.text('No tasks yet.'), findsNothing);
    });

    testWidgets('submitting an empty title shows a validation error', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('save-task-button')));
      await tester.pumpAndSettle();

      expect(find.text('Title cannot be empty'), findsOneWidget);
    });

    testWidgets('a user can add multiple tasks one after another', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      for (final title in ['Buy groceries', 'Write tests', 'Deploy app']) {
        await tester.enterText(
          find.byKey(const Key('task-title-field')),
          title,
        );
        await tester.tap(find.byKey(const Key('save-task-button')));
        await tester.pumpAndSettle();
      }

      expect(find.text('Buy groceries'), findsOneWidget);
      expect(find.text('Write tests'), findsOneWidget);
      expect(find.text('Deploy app'), findsOneWidget);
    });
  });
}
