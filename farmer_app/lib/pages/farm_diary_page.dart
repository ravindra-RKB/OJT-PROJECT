import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/diary_provider.dart';
import '../models/farm_diary_entry.dart';

class FarmDiaryPage extends StatefulWidget {
  const FarmDiaryPage({super.key});

  @override
  State<FarmDiaryPage> createState() => _FarmDiaryPageState();
}

class _FarmDiaryPageState extends State<FarmDiaryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DiaryProvider>().init().then((_) {
        if (!mounted) return;
        context.read<DiaryProvider>().loadEntries();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EFE7),
      appBar: AppBar(
        title: const Text('Farm Diary'),
        backgroundColor: const Color(0xFF617A2E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEntryDialog(context),
          ),
        ],
      ),
      body: Consumer<DiaryProvider>(
        builder: (context, diaryProvider, child) {
          if (diaryProvider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (diaryProvider.entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No diary entries yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap + to add your first entry',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: diaryProvider.entries.length,
            itemBuilder: (context, index) {
              final entry = diaryProvider.entries[index];
              return _buildDiaryCard(context, entry, diaryProvider);
            },
          );
        },
      ),
    );
  }

  Widget _buildDiaryCard(
      BuildContext context, FarmDiaryEntry entry, DiaryProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  entry.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditEntryDialog(context, entry, provider);
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(context, entry, provider);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('dd MMM yyyy, hh:mm a').format(entry.date),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          if (entry.cropType != null) ...[
            const SizedBox(height: 8),
            Chip(
              label: Text(entry.cropType!),
              backgroundColor: const Color(0xFF617A2E).withValues(alpha: 0.1),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            entry.description,
            style: const TextStyle(fontSize: 14),
          ),
          if (entry.fieldLocation != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  entry.fieldLocation!,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showAddEntryDialog(BuildContext context) {
    _showEntryDialog(context, null);
  }

  void _showEditEntryDialog(
      BuildContext context, FarmDiaryEntry entry, DiaryProvider provider) {
    _showEntryDialog(context, entry);
  }

  void _showEntryDialog(BuildContext context, FarmDiaryEntry? entry) {
    final titleController =
        TextEditingController(text: entry?.title ?? '');
    final descriptionController =
        TextEditingController(text: entry?.description ?? '');
    final cropTypeController =
        TextEditingController(text: entry?.cropType ?? '');
    final locationController =
        TextEditingController(text: entry?.fieldLocation ?? '');
    DateTime selectedDate = entry?.date ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(entry == null ? 'Add Entry' : 'Edit Entry'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: cropTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Crop Type (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Field Location (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text(DateFormat('dd MMM yyyy, hh:mm a')
                      .format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null && context.mounted) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(selectedDate),
                      );
                      if (time != null && context.mounted) {
                        setState(() {
                          selectedDate = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newEntry = FarmDiaryEntry(
                  id: entry?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  description: descriptionController.text,
                  date: selectedDate,
                  cropType: cropTypeController.text.isEmpty
                      ? null
                      : cropTypeController.text,
                  fieldLocation: locationController.text.isEmpty
                      ? null
                      : locationController.text,
                );

                if (entry == null) {
                  context.read<DiaryProvider>().addEntry(newEntry);
                } else {
                  context.read<DiaryProvider>().updateEntry(newEntry);
                }

                Navigator.pop(context);
              },
              child: Text(entry == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, FarmDiaryEntry entry, DiaryProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteEntry(entry.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

