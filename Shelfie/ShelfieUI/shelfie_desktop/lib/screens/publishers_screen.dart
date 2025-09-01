import 'package:flutter/material.dart';
import '../models/publisher.dart';
import '../providers/publisher_provider.dart';
import 'add_edit_publisher_screen.dart';

class PublishersScreen extends StatefulWidget {
  final String authHeader;
  const PublishersScreen({required this.authHeader, Key? key}) : super(key: key);

  @override
  _PublishersScreenState createState() => _PublishersScreenState();
}

class _PublishersScreenState extends State<PublishersScreen> {
  final PublisherProvider _publisherProvider = PublisherProvider();
  List<Publisher> _publishers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _sortOrder = 'A-Z';

  int _currentPage = 1;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadPublishers();
  }

  Future<void> _loadPublishers() async {
    try {
      var publishers = await _publisherProvider.getAll(widget.authHeader);
      setState(() {
        _publishers = publishers;
        _sortPublishers();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _sortPublishers() {
    if (_sortOrder == 'A-Z') {
      _publishers.sort((a, b) => a.name.compareTo(b.name));
    } else {
      _publishers.sort((a, b) => b.name.compareTo(a.name));
    }
  }

  Future<void> _searchPublishers(String query) async {
    setState(() => _isLoading = true);
    try {
      var publishers = await _publisherProvider.searchPublishers(widget.authHeader, query);
      setState(() {
        _publishers = publishers;
        _isLoading = false;
        _currentPage = 1;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (_publishers.length / _itemsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (_currentPage * _itemsPerPage < _publishers.length)
        ? _currentPage * _itemsPerPage
        : _publishers.length;
    final pagePublishers = _publishers.sublist(startIndex, endIndex);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Publishers'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search publishers',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      _searchQuery = value;
                      _searchPublishers(value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButtonHideUnderline(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButton<String>(
                        value: _sortOrder,
                        items: const [
                          DropdownMenuItem(value: 'A-Z', child: Text('A-Z')),
                          DropdownMenuItem(value: 'Z-A', child: Text('Z-A')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _sortOrder = value!;
                            _sortPublishers();
                            _currentPage = 1;
                          });
                        },
                        dropdownColor: Colors.deepPurple[50],
                        style: const TextStyle(color: Colors.black, fontSize: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEditPublisherScreen(authHeader: widget.authHeader),
                      ),
                    ).then((value) {
                      if (value == true) {
                        _loadPublishers();
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                  ),
                  child: const Text("Add new Publisher", style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _isLoading
                ? const Expanded(child: Center(child: CircularProgressIndicator()))
                : Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                        child: DataTable(
                          columnSpacing: 20,
                          columns: const [
                            DataColumn(label: Text('ID')),
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('HQ Location')),
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Phone')),
                            DataColumn(label: Text('Year Founded')),
                            DataColumn(label: Text('Country')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: pagePublishers.map((publisher) {
                            return DataRow(cells: [
                              DataCell(Text(publisher.id.toString())),
                              DataCell(Text(publisher.name)),
                              DataCell(Text(publisher.headquartersLocation)),
                              DataCell(Text(publisher.contactEmail)),
                              DataCell(Text(publisher.contactPhone ?? '')),
                              DataCell(Text(publisher.yearFounded.toString())),
                              DataCell(Text(publisher.country)),
                              DataCell(Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddEditPublisherScreen(
                                            authHeader: widget.authHeader,
                                            publisherId: publisher.id,
                                          ),
                                        ),
                                      ).then((value) {
                                        if (value == true) {
                                          _loadPublishers();
                                        }
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text('Confirm Delete'),
                                          content: const Text('Are you sure you want to delete this publisher?'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        try {
                                          await _publisherProvider.deletePublisher(widget.authHeader, publisher.id);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Publisher deleted successfully!'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                          _loadPublishers();
                                        } catch (e) {
                                          String errorMsg = e.toString();
                                          if (errorMsg.startsWith("Exception: ")) {
                                            errorMsg = errorMsg.replaceFirst("Exception: ", "");
                                          }
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(errorMsg),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ],
                              )),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                  ),
                  Text('$_currentPage / $totalPages'),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
