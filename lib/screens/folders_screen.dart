import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/folder.dart';
import '../services/notes_database.dart';
import '../theme/app_theme.dart';
import 'notes_list_screen.dart';

class FoldersScreen extends StatefulWidget {
  const FoldersScreen({super.key});

  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  final _uuid = const Uuid();
  List<Folder> _folders = [];

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  void _loadFolders() {
    setState(() {
      _folders = NotesDatabase.getAllFolders()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    });
  }

  Future<void> _createFolder() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('New Folder', style: TextStyle(color: AppColors.gold)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'Folder name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Create', style: TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      final folder = Folder(id: _uuid.v4(), name: name, createdAt: DateTime.now());
      await NotesDatabase.saveFolder(folder);
      _loadFolders();
    }
  }

  Future<void> _deleteFolder(Folder folder) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Folder?', style: TextStyle(color: AppColors.gold)),
        content: Text(
          'This will delete "${folder.name}" and all notes inside it.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
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
      await NotesDatabase.deleteFolder(folder.id);
      _loadFolders();
    }
  }

  int _noteCount(String folderId) =>
      NotesDatabase.getNotesByFolder(folderId).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Golden Notes'),
        centerTitle: false,
      ),
      body: _folders.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: _folders.length,
              itemBuilder: (context, index) {
                final folder = _folders[index];
                return _FolderTile(
                  folder: folder,
                  noteCount: _noteCount(folder.id),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NotesListScreen(folder: folder),
                      ),
                    );
                    _loadFolders();
                  },
                  onDelete: () => _deleteFolder(folder),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createFolder,
        icon: const Icon(Icons.create_new_folder_outlined),
        label: const Text('New Folder', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_open_outlined, size: 72, color: AppColors.goldMuted),
          const SizedBox(height: 16),
          const Text(
            'No folders yet',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap "New Folder" to get started',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _FolderTile extends StatelessWidget {
  final Folder folder;
  final int noteCount;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _FolderTile({
    required this.folder,
    required this.noteCount,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.goldMuted.withOpacity(0.18),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.folder, color: AppColors.gold),
        ),
        title: Text(
          folder.name,
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          '$noteCount ${noteCount == 1 ? "note" : "notes"}',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.textSecondary),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
