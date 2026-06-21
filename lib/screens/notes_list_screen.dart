import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/folder.dart';
import '../models/note.dart';
import '../services/notes_database.dart';
import '../theme/app_theme.dart';
import 'note_view_screen.dart';

class NotesListScreen extends StatefulWidget {
  final Folder folder;
  const NotesListScreen({super.key, required this.folder});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final _uuid = const Uuid();
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() {
    setState(() {
      _notes = NotesDatabase.getNotesByFolder(widget.folder.id)
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    });
  }

  Future<void> _createNote() async {
    final note = Note(
      id: _uuid.v4(),
      title: '',
      content: '',
      folderId: widget.folder.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteViewScreen(note: note, startInEditMode: true, isNewNote: true),
      ),
    );

    if (result == true) _loadNotes();
  }

  Future<void> _deleteNote(Note note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Note?', style: TextStyle(color: AppColors.gold)),
        content: const Text('This cannot be undone.', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await NotesDatabase.deleteNote(note.id);
      _loadNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.folder.name)),
      body: _notes.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return _NoteCard(
                  note: note,
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NoteViewScreen(note: note, startInEditMode: false),
                      ),
                    );
                    if (result == true || result == 'deleted') _loadNotes();
                  },
                  onDelete: () => _deleteNote(note),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNote,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.note_alt_outlined, size: 72, color: AppColors.goldMuted),
          const SizedBox(height: 16),
          const Text(
            'No notes here yet',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + to write your first note',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NoteCard({required this.note, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final displayTitle = note.title.trim().isEmpty ? 'Untitled' : note.title;
    final preview = note.content.trim().replaceAll('\n', ' ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
        title: Text(
          displayTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              preview.isEmpty ? 'No content' : preview,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              DateFormat('MMM d, yyyy · h:mm a').format(note.updatedAt),
              style: const TextStyle(color: AppColors.goldMuted, fontSize: 11),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.textSecondary),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
