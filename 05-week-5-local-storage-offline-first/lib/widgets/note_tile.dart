import 'package:flutter/material.dart';
import '../data/local/note.dart';

class NoteTile extends StatelessWidget {
  const NoteTile({
    super.key,
    required this.note,
    this.onTap,
    this.onDelete,
  });

  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(note.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(note.body, maxLines: 2, overflow: TextOverflow.ellipsis),
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (note.dirty)
            const Tooltip(
              message: 'Belum tersinkron',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off, size: 16, color: Colors.orange),
                  SizedBox(width: 4),
                  Text('Unsynced',
                      style: TextStyle(fontSize: 12, color: Colors.orange)),
                ],
              ),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Hapus',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}