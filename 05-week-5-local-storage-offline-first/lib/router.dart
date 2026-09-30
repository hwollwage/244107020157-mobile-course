import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pages/note_detail_page.dart';
import 'pages/notes_page.dart';
import 'pages/posts_page.dart';
import 'pages/settings_page.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const NotesPage()),
    GoRoute(path: '/settings', builder: (context, state) => const SettingsPage()),
    GoRoute(path: '/posts', builder: (context, state) => const PostsPage()),
    GoRoute(
      path: '/note/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const Scaffold(body: Center(child: Text('ID tidak valid')));
        }
        return NoteDetailPage(noteId: id);
      },
    ),
  ],
);