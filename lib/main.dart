import 'package:flutter/material.dart';

void main() {
  runApp(const ReadingTrackerApp());
}

class ReadingTrackerApp extends StatelessWidget {
  const ReadingTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reading Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      home: const ReadingHomeScreen(),
    );
  }
}

class BookItem {
  final String id;
  final String title;
  final String author;
  final int totalPages;
  int readPages;

  BookItem({
    required this.id,
    required this.title,
    required this.author,
    required this.totalPages,
    this.readPages = 0,
  });

  double get progress =>
      totalPages > 0 ? (readPages / totalPages).clamp(0.0, 1.0) : 0.0;
  bool get isFinished => readPages >= totalPages;
}

class ReadingHomeScreen extends StatefulWidget {
  const ReadingHomeScreen({super.key});

  @override
  State<ReadingHomeScreen> createState() => _ReadingHomeScreenState();
}

class _ReadingHomeScreenState extends State<ReadingHomeScreen> {
  final List<BookItem> _books = [
    BookItem(
      id: '1',
      title: 'Clean Architecture',
      author: 'Robert C. Martin',
      totalPages: 432,
      readPages: 290,
    ),
    BookItem(
      id: '2',
      title: 'Atomic Habits',
      author: 'James Clear',
      totalPages: 320,
      readPages: 320,
    ),
    BookItem(
      id: '3',
      title: 'Flutter in Action',
      author: 'Eric Windmill',
      totalPages: 368,
      readPages: 145,
    ),
  ];

  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _pagesController = TextEditingController();

  int get _finishedBooksCount => _books.where((b) => b.isFinished).length;

  void _incrementPages(BookItem book, int pages) {
    setState(() {
      book.readPages = (book.readPages + pages).clamp(0, book.totalPages);
    });
  }

  void _addBook() {
    final title = _titleController.text.trim();
    final author = _authorController.text.trim();
    final pages = int.tryParse(_pagesController.text.trim()) ?? 0;

    if (title.isEmpty || author.isEmpty || pages <= 0) return;

    setState(() {
      _books.insert(
        0,
        BookItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          author: author,
          totalPages: pages,
        ),
      );
    });

    _titleController.clear();
    _authorController.clear();
    _pagesController.clear();
    Navigator.of(context).pop();
  }

  void _openAddDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add New Book'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Book Title'),
              ),
              TextField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'Author'),
              ),
              TextField(
                controller: _pagesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Total Pages'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(onPressed: _addBook, child: const Text('Add')),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reading Tracker'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.brown.shade700,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _headerStat('Total Books', '${_books.length}'),
                  _headerStat('Completed', '$_finishedBooksCount'),
                  _headerStat(
                    'In Progress',
                    '${_books.length - _finishedBooksCount}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _books.length,
                itemBuilder: (ctx, index) {
                  final book = _books[index];
                  final percent = (book.progress * 100).toInt();

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      book.title,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      book.author,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (book.isFinished)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                              else
                                FilledButton.tonal(
                                  onPressed: () => _incrementPages(book, 15),
                                  child: const Text('+15 pgs'),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: book.progress,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${book.readPages} / ${book.totalPages} pages',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '$percent%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddDialog,
        child: const Icon(Icons.book),
      ),
    );
  }

  Widget _headerStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }
}
