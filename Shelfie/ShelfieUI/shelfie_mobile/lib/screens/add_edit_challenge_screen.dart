import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/readingChallenge.dart';
import '../utils/api_helpers.dart';

Future<ReadingChallenge> fetchReadingChallenge(String authHeader,int challengeId) async {
  final response= await http.get(
      Uri.parse('$baseUrl/ReadingChallenge/$challengeId'),
      headers: {
        'authorization': authHeader,
        'content-type': 'application/json',
      }
  );
  if (response.statusCode == 200) {
    try {
      final book = jsonDecode(response.body);
      return ReadingChallenge.fromJson(book);
    } catch (e) {
      throw Exception('Error processing data');
    }
  } else {
    throw Exception('Failed to load ReadingChallenge details');
  }
}

Future<ReadingChallenge> addChallenge(String authHeader, int userId, String challengeName, String description, int goalType, int goalAmount,
    DateTime startDate, DateTime endDate, int progress, bool isCompleted) async {

  final uri = Uri.parse('$baseUrl/ReadingChallenge');

  final response = await http.post(
    uri,
    headers:  {
      'authorization': authHeader,
      'content-type': 'application/json',
    },
    body: jsonEncode({
      'userId': userId,
      'challengeName': challengeName,
      'description': description,
      'goalType': goalType,
      'goalAmount': goalAmount,
      'startDate': DateFormat('yyyy-MM-dd').format(startDate),
      'endDate': DateFormat('yyyy-MM-dd').format(endDate),
      'progress': progress,
      'isCompleted': isCompleted,
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    try {
      final data = jsonDecode(response.body);
      return ReadingChallenge.fromJson(data);
    } catch (e) {
      print('JSON parsing error: $e');
      throw Exception('Failed to parse Reading Challenge response');
    }
  } else {
    print('Add new challenge failed: ${response.body}');
    throw Exception('Failed to add new challenge');
  }
}



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
    }
  }

  Future<void> updateChallenge(int id) async {
    Map<String, dynamic> data = {};

    if (challengeNameController.text.trim().isNotEmpty) {
      data['challengeName'] = challengeNameController.text.trim();
    }
    if (descriptionController.text.trim().isNotEmpty) {
      data['description'] = descriptionController.text.trim();
    }
    if (goalAmountController.text.trim().isNotEmpty) {
      data['goalAmount'] = int.tryParse(goalAmountController.text.trim()) ?? 0;
    }
    data['goalType'] = selectedGoalType;
    if (startDate != null) {
      data['startDate'] = DateFormat('yyyy-MM-dd').format(startDate!);
    }
    if (endDate != null) {
      data['endDate'] = DateFormat('yyyy-MM-dd').format(endDate!);
    }

    data['progress'] = int.tryParse(progressController.text.trim()) ?? 0;
    data['isCompleted'] = isCompleted;

    if (data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No changes to save')),
      );
      return;
    }

    final response = await http.put(
      Uri.parse('$baseUrl/ReadingChallenge/$id'),
      headers: {
        'authorization': widget.authHeader,
        'content-type': 'application/json',
      },
      body: jsonEncode(data),
    );

    print('Update response status: ${response.statusCode}');
    print('Update response body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Challenge updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Future.delayed(Duration(seconds: 1), () {
        if (!mounted) return;
        Navigator.pop(context, true);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update challenge'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  Future<void> _loadChallenge() async {
    setState(() => isLoading = true);
    final challenge = await fetchReadingChallenge(widget.authHeader, widget.challengeId!);

    challengeNameController.text = challenge.challengeName;
    descriptionController.text = challenge.description;
    goalAmountController.text = challenge.goalAmount.toString();
    selectedGoalType = int.tryParse(challenge.goalType) ?? 1;
    startDate = challenge.startDate;
    endDate = challenge.endDate;
    progressController.text = challenge.progress.toString();
    isCompleted = challenge.isCompleted;

    setState(() => isLoading = false);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || startDate == null || endDate == null) return;

    setState(() => isLoading = true);

    try {
      final name = challengeNameController.text.trim();
      final desc = descriptionController.text.trim();
      final goalAmount = int.tryParse(goalAmountController.text.trim()) ?? 0;
      if ((int.tryParse(progressController.text.trim()) ?? 0) >= goalAmount) {
        isCompleted = true;
      } else {
        isCompleted = false;
      }

      if (widget.challengeId == null) {
        await addChallenge(
          widget.authHeader,
          widget.userId,
          name,
          desc,
          selectedGoalType,
          goalAmount,
          startDate!,
          endDate!,
          int.tryParse(progressController.text.trim()) ?? 0,
          isCompleted,
        );
      } else {
        print('Progress value: "${progressController.text}"');
        await updateChallenge(
            widget.challengeId!
        );
      }

      Navigator.pop(context, true);
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
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

              CheckboxListTile(
                title: Text('Completed'),
                value: isCompleted,
                onChanged: (val) {
                  setState(() {
                    isCompleted = val ?? false;
                  });
                },
              ),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: _submit,
                child: Text(widget.challengeId == null ? 'Create Challenge' : 'Update Challenge'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple,foregroundColor: Colors.white),
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
