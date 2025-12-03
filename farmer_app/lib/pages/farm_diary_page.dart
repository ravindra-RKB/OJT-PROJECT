import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/diary_provider.dart';
import '../models/farm_diary_entry.dart';
import '../services/field_condition_service.dart';

class FarmDiaryPage extends StatefulWidget {
  const FarmDiaryPage({super.key});

  @override
  State<FarmDiaryPage> createState() => _FarmDiaryPageState();
}

class _FarmDiaryPageState extends State<FarmDiaryPage> {
  String _searchQuery = '';
  final FieldConditionService _conditionService = FieldConditionService();
  bool _conditionsLoading = false;
  String? _conditionsError;
  FieldConditionData? _fieldCondition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DiaryProvider>().init().then((_) {
        if (!mounted) return;
        context.read<DiaryProvider>().loadEntries();
      });
      _loadFieldConditions();
    });
  }

  Future<void> _loadFieldConditions() async {
    setState(() {
      _conditionsLoading = true;
      _conditionsError = null;
    });
    try {
      final data = await _conditionService.fetchConditions();
      if (!mounted) return;
      setState(() {
        _fieldCondition = data;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _conditionsError = 'Could not fetch field conditions. Please try again.';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _conditionsLoading = false;
      });
    }
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
          final filteredEntries = diaryProvider.entries.where((entry) {
            if (_searchQuery.isEmpty) return true;
            final q = _searchQuery.toLowerCase();
            return entry.title.toLowerCase().contains(q) ||
                entry.description.toLowerCase().contains(q) ||
                (entry.cropType != null &&
                    entry.cropType!.toLowerCase().contains(q)) ||
                (entry.fieldLocation != null &&
                    entry.fieldLocation!.toLowerCase().contains(q));
          }).toList();

          return Column(
            children: [
              _buildFieldConditionSection(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by title, crop, or location',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: filteredEntries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.book_outlined,
                                size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              diaryProvider.entries.isEmpty
                                  ? 'No diary entries yet'
                                  : 'No entries match your search',
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              diaryProvider.entries.isEmpty
                                  ? 'Tap + to add your first entry'
                                  : 'Try changing your search keywords',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredEntries.length,
                        itemBuilder: (context, index) {
                          final entry = filteredEntries[index];
                          return _buildDiaryCard(
                              context, entry, diaryProvider);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFieldConditionSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        width: double.infinity,
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
        child: _conditionsLoading
            ? Row(
                children: const [
                  CircularProgressIndicator(strokeWidth: 2),
                  SizedBox(width: 12),
                  Text('Loading field conditions...'),
                ],
              )
            : _conditionsError != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Field Insights',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _conditionsError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                      TextButton.icon(
                        onPressed: _loadFieldConditions,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  )
                : _fieldCondition == null
                    ? const Text('No field data available yet.')
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Field Insights',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _buildConditionChip(
                                icon: Icons.thermostat,
                                label:
                                    '${_fieldCondition!.temperature.toStringAsFixed(1)}°C',
                                description: 'Air Temperature',
                                color: Colors.orange,
                              ),
                              _buildConditionChip(
                                icon: Icons.water_drop,
                                label:
                                    '${_fieldCondition!.humidity.toStringAsFixed(0)}%',
                                description: 'Humidity',
                                color: Colors.blue,
                              ),
                              _buildConditionChip(
                                icon: Icons.ac_unit,
                                label:
                                    '${_fieldCondition!.apparentTemperature.toStringAsFixed(1)}°C',
                                description: 'Feels Like',
                                color: Colors.teal,
                              ),
                              _buildConditionChip(
                                icon: Icons.grain,
                                label:
                                    '${_fieldCondition!.precipitation.toStringAsFixed(1)} mm',
                                description: 'Precipitation',
                                color: Colors.green,
                              ),
                            ],
                          ),
                          if (_fieldCondition != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Updated ${DateFormat('hh:mm a').format(_fieldCondition!.fetchedAt)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                        ],
                      ),
      ),
    );
  }

  Widget _buildConditionChip({
    required IconData icon,
    required String label,
    required String description,
    required Color color,
  }) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
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

