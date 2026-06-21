import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../services/notes_database.dart';
import '../theme/app_theme.dart';

class NoteViewScreen extends StatefulWidget {
  final Note note;
  final bool startInEditMode;
  final bool isNewNote;

  const NoteViewScreen({
    super.key,
    required this.note,
    this.startInEditMode = false,
    this.isNewNote = false,
  });

  @override
  State<NoteViewScreen> createState() => _NoteViewScreenState();
}

class _NoteViewScreenState extends State<NoteViewScreen> {
  late bool _isEditing;
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _hasUnsavedChanges = false;
  bool _wasEverSaved = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.startInEditMode;
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _wasEverSaved = !widget.isNewNote;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final content = _contentController.text;

    // Don't save a completely empty new note
    if (widget.isNewNote && !_wasEverSaved && title.isEmpty && content.trim().isEmpty) {
      return;
    }

    widget.note.title = title;
    widget.note.content = content;
    widget.note.updatedAt = DateTime.now();
    await NotesDatabase.saveNote(widget.note);
    _wasEverSaved = true;
    _hasUnsavedChanges = false;
  }

  Future<bool> _handleBack() async {
    if (_isEditing) {
      await _save();
      if (!_wasEverSaved) {
        // was empty, nothing saved
        return true;
      }
      setState(() => _isEditing = false);
      return false; // stay on screen, switch to view mode
    }
    return true;
  }

  Future<void> _toggleEdit() async {
    if (_isEditing) {
      await _save();
      if (!_wasEverSaved) {
        if (mounted) Navigator.pop(context, false);
        return;
      }
      setState(() => _isEditing = false);
    } else {
      setState(() => _isEditing = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBack,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final shouldPop = await _handleBack();
              if (shouldPop && mounted) {
                Navigator.pop(context, _wasEverSaved);
              }
            },
          ),
          title: Text(_isEditing ? 'Editing' : 'Note'),
          actions: [
            IconButton(
              icon: Icon(
                _isEditing ? Icons.check : Icons.edit_outlined,
                color: AppColors.gold,
              ),
              tooltip: _isEditing ? 'Save' : 'Edit',
              onPressed: _toggleEdit,
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _isEditing
                  ? TextField(
                      controller: _titleController,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Title',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (_) => _hasUnsavedChanges = true,
                    )
                  : Text(
                      _titleController.text.trim().isEmpty ? 'Untitled' : _titleController.text,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
              const SizedBox(height: 4),
              Text(
                'Last edited ${DateFormat('MMM d, yyyy · h:mm a').format(widget.note.updatedAt)}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 14),
              const Divider(color: AppColors.divider, height: 1),
              const SizedBox(height: 14),
              Expanded(
                child: _isEditing
                    ? TextField(
                        controller: _contentController,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          height: 1.5,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Start writing...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (_) => _hasUnsavedChanges = true,
                      )
                    : SingleChildScrollView(
                        child: Text(
                          _contentController.text.isEmpty
                              ? 'Nothing written yet. Tap the pencil icon to start editing.'
                              : _contentController.text,
                          style: TextStyle(
                            color: _contentController.text.isEmpty
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
