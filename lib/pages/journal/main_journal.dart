import 'package:flutter/material.dart';
import 'package:flutter_application_2/pages/journal/journal_entry.dart';
import 'dart:io';
import '../../utils/file_handler.dart';
import 'package:intl/intl.dart';

class MainJournal extends StatefulWidget {
  const MainJournal({Key? key}) : super(key: key);

  @override
  _MainJournalState createState() => _MainJournalState();
}

class _MainJournalState extends State<MainJournal> {
  List<Map<String, String>> _journalEntries = []; // Store content and date
  bool _isLoading = true;
  bool _isLoadingMore = false; // To track if more items are being loaded
  int _currentBatchSize = 10; // Number of items to load per batch
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadJournalEntries();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadJournalEntries({int start = 0}) async {
    setState(() {
      _isLoading = start == 0;
      _isLoadingMore = start > 0;
    });

    try {
      List<File> latestFiles = await getLatestTextFiles(_currentBatchSize, start);

      List<Map<String, String>> newEntries = [];
      for (File file in latestFiles) {
        String content = await file.readAsString();
        String filename = file.path.split('/').last;

        String formattedDate = _extractAndFormatDateFromFilename(filename);

        newEntries.add({
          'date': formattedDate,
          'content': content,
        });
      }

      setState(() {
        _journalEntries.addAll(newEntries);
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
      print('Error loading journal entries: $e');
    }
  }

  String _extractAndFormatDateFromFilename(String filename) {
    try {
      String datePart = filename.split('-').first;
      DateTime parsedDate = DateTime.parse(
        '${datePart.substring(0, 4)}-${datePart.substring(4, 6)}-${datePart.substring(6, 8)}',
      );

      return DateFormat('EEEE, d.M.yyyy').format(parsedDate);
    } catch (e) {
      print('Error parsing date from filename: $e');
      return 'Unknown Date';
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more entries if we are near the bottom of the list
      if (!_isLoadingMore) {
        _loadJournalEntries(start: _journalEntries.length);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _journalEntries.length + 1, // Extra item for loading indicator
                  itemBuilder: (context, index) {
                    if (index == _journalEntries.length) {
                      // Show loading indicator at the bottom
                      return _isLoadingMore
                          ? const Center(child: CircularProgressIndicator())
                          : const SizedBox.shrink();
                    }

                    final entry = _journalEntries[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      child: ListTile(
                        title: Text(
                          entry['date'] ?? 'Unknown Date',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JournalEntryDetailView(
                                content: entry['content'] ?? '',
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              if (_isLoadingMore)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
            ],
          );
  }
}
