import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/shelfBooks.dart';
import '../providers/reading_challenge_provider.dart';
import '../providers/shelf_books_provider.dart';
import '../providers/shelf_provider.dart';

class AddEditChallengeScreen extends StatefulWidget {
  final String authHeader;
  final int userId;
  final int? challengeId;

  AddEditChallengeScreen({
    required this.authHeader,
    required this.userId,
    this.challengeId,
  });

  @override
  _AddEditChallengeScreenState createState() => _AddEditChallengeScreenState();
}

class _AddEditChallengeScreenState extends State<AddEditChallengeScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController challengeNameController;
  late TextEditingController descriptionController;
  late TextEditingController goalAmountController;
  late TextEditingController progressController;

  final ReadingChallengeProvider _provider = ReadingChallengeProvider();

  final _shelfBooksProvider = ShelfBooksProvider();
  final _shelfProvider = ShelfProvider();
  int shelfReadId=0;
  int selectedGoalType = 1;
  DateTime? startDate;
  DateTime? endDate;
  bool isLoading = false;
  bool isCompleted = false;

  @override
  void initState() {
    super.initState();

    challengeNameController = TextEditingController();
    descriptionController = TextEditingController();
    goalAmountController = TextEditingController();
    progressController = TextEditingController();

    if (widget.challengeId != null) {
      _loadChallenge();
      getReadShelfId();
    }
  }

  void getReadShelfId() async {
    final shelves = await _shelfProvider.getAll(widget.authHeader);
    final readShelf = shelves.firstWhere(
          (shelf) => shelf.name.toLowerCase() == 'read',
      orElse: () => shelves.first,
    );
    setState(() {
      shelfReadId = readShelf.id;
    });

  }

  Future<void> _loadChallenge() async {
    setState(() => isLoading = true);
    final challenge = await _provider.getById(widget.authHeader, widget.challengeId!);

    challengeNameController.text = challenge.challengeName;
    descriptionController.text = challenge.description;
    goalAmountController.text = challenge.goalAmount.toString();
    selectedGoalType = challenge.goalType.toLowerCase() == 'books' ? 1 : 0;
    startDate = challenge.startDate;
    endDate = challenge.endDate;
    progressController.text = challenge.progress.toString();
    isCompleted = challenge.isCompleted;

    setState(() => isLoading = false);
  }

  Future<void> _submit() async {
    bool isValid = _formKey.currentState!.validate();
    bool datesValid = startDate != null && endDate != null;

    if (!datesValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both start and end dates"), backgroundColor: Colors.red),
      );
    }

    if (!isValid || !datesValid) return;

    setState(() => isLoading = true);

    try {
      final name = challengeNameController.text.trim();
      final desc = descriptionController.text.trim();
      final goalAmount = int.tryParse(goalAmountController.text.trim()) ?? 0;
      int progress = int.tryParse(progressController.text.trim()) ?? 0;

      if (progress >= goalAmount) isCompleted = true;

      if (widget.challengeId == null) {
        await _provider.addChallenge(
          widget.authHeader,
          widget.userId,
          name,
          desc,
          selectedGoalType,
          goalAmount,
          startDate!,
          endDate!,
          progress,
          isCompleted,
        );
      } else {
        await _provider.updateChallenge(widget.authHeader, widget.challengeId!, {
          'challengeName': name,
          'description': desc,
          'goalAmount': goalAmount,
          'goalType': selectedGoalType,
          'startDate': DateFormat('yyyy-MM-dd').format(startDate!),
          'endDate': DateFormat('yyyy-MM-dd').format(endDate!),
          'progress': progress,
          'isCompleted': isCompleted,
        });
      }

      Navigator.pop(context, true);
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }



  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) startDate = picked;
        else endDate = picked;
      });
    }
  }

  @override
  void dispose() {
    challengeNameController.dispose();
    descriptionController.dispose();
    goalAmountController.dispose();
    progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.challengeId == null ? 'Add Challenge' : 'Edit Challenge'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(challengeNameController, 'Challenge Name'),
              _buildTextField(descriptionController, 'Description', maxLines: 3),
              DropdownButtonFormField<int>(
                value: selectedGoalType,
                decoration: InputDecoration(labelText: 'Goal Type'),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Books')),
                  DropdownMenuItem(value: 0, child: Text('Pages')),
                ],
                onChanged: (val) => setState(() => selectedGoalType = val!),
              ),
              SizedBox(height: 16),
              _buildTextField(goalAmountController, 'Goal Amount', keyboardType: TextInputType.number),
              SizedBox(height: 16),
              Row(
                children: [
                  Text(startDate == null
                      ? 'Start Date: Not selected'
                      : 'Start: ${DateFormat('dd.MM.yyyy').format(startDate!)}'),
                  Spacer(),
                  TextButton(onPressed: () => _pickDate(isStart: true), child: Text('Pick Start Date')),
                ],
              ),
              Row(
                children: [
                  Text(endDate == null
                      ? 'End Date: Not selected'
                      : 'End: ${DateFormat('dd.MM.yyyy').format(endDate!)}'),
                  Spacer(),
                  TextButton(onPressed: () => _pickDate(isStart: false), child: Text('Pick End Date')),
                ],
              ),
              _buildTextField(progressController, 'Progress', keyboardType: TextInputType.number),

            /*  CheckboxListTile(
                title: Text('Completed'),
                value: isCompleted,
                onChanged: (val) {
                  setState(() {
                    isCompleted = val ?? false;
                  });
                },
              ),*/
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: _submit,
                child: Text(widget.challengeId == null ? 'Create Challenge' : 'Update Challenge'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple,foregroundColor: Colors.white),
              ),
              SizedBox(height: 12),
              Text("Books read in this challenge:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              FutureBuilder<List<ShelfBooks>>(
                future: _shelfBooksProvider.getByShelfId(widget.authHeader, shelfReadId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text("No books found in Read shelf");
                  }

                  final booksInChallenge = snapshot.data!.where((sb) {
                    return sb.createdAt.isAfter(startDate!) &&
                        sb.createdAt.isBefore(endDate!);
                  }).toList();

                  if (booksInChallenge.isEmpty) {
                    return Text("No books read in this period");
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: booksInChallenge.length,
                    itemBuilder: (context, index) {
                      final book = booksInChallenge[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: book.photoUrl != null
                              ? Image.network(book.photoUrl!, width: 40, height: 60, fit: BoxFit.cover)
                              : Icon(Icons.book, size: 40, color: Colors.deepPurple),
                          title: Text(book.bookTitle ?? ""),
                          subtitle: Text(book.authorName ?? ""),
                        ),
                      );
                    },
                  );
                },
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
      ),
    );
  }
}
