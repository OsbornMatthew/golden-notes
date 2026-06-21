import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';
import '../models/folder.dart';

class NotesDatabase {
  static const String notesBoxName = 'notes';
  static const String foldersBoxName = 'folders';

  static Box<Note>? _notesBox;
  static Box<Folder>? _foldersBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(NoteAdapter());
    Hive.registerAdapter(FolderAdapter());
    _notesBox = await Hive.openBox<Note>(notesBoxName);
    _foldersBox = await Hive.openBox<Folder>(foldersBoxName);
  }

  static Box<Note> get notesBox => _notesBox!;
  static Box<Folder> get foldersBox => _foldersBox!;

  // Notes
  static List<Note> getAllNotes() => notesBox.values.toList();

  static List<Note> getNotesByFolder(String folderId) =>
      notesBox.values.where((n) => n.folderId == folderId).toList();

  static Future<void> saveNote(Note note) async {
    await notesBox.put(note.id, note);
  }

  static Future<void> deleteNote(String id) async {
    await notesBox.delete(id);
  }

  // Folders
  static List<Folder> getAllFolders() => foldersBox.values.toList();

  static Future<void> saveFolder(Folder folder) async {
    await foldersBox.put(folder.id, folder);
  }

  static Future<void> deleteFolder(String id) async {
    // Also delete all notes within this folder
    final notesToDelete =
        notesBox.values.where((n) => n.folderId == id).map((n) => n.id).toList();
    for (final noteId in notesToDelete) {
      await notesBox.delete(noteId);
    }
    await foldersBox.delete(id);
  }
}
