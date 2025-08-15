import 'package:flutter/material.dart';
import '../models/author.dart';
import '../providers/author_provider.dart';
import 'package:intl/intl.dart';

class AddEditAuthorScreen extends StatefulWidget {
  final String authHeader;
  final int? authorId;

  const AddEditAuthorScreen({required this.authHeader, this.authorId, Key? key}) : super(key: key);

  @override
  _AddEditAuthorScreenState createState() => _AddEditAuthorScreenState();
}

class _AddEditAuthorScreenState extends State<AddEditAuthorScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthorProvider _authorProvider = AuthorProvider();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthCountryController = TextEditingController();
  final TextEditingController _shortBioController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _deathDateController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  DateTime? _birthDate;
  DateTime? _deathDate;
  Author? _author;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() => _isLoading = true);
    if (widget.authorId != null) {
      await _loadAuthor(widget.authorId!);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadAuthor(int id) async {
    try {
      _author = await _authorProvider.getById(widget.authHeader, id);
      setState(() {
        _firstNameController.text = _author!.firstName;
        _lastNameController.text = _author!.lastName;
        _birthCountryController.text = _author!.birthCountry ?? '';
        _shortBioController.text = _author!.shortBio ?? '';
        if (_author!.birthDate != null) {
          _birthDate = _author!.birthDate;
          _birthDateController.text = DateFormat('dd.MM.yyyy').format(_birthDate!);
        }
        if (_author!.deathDate != null) {
          _deathDate = _author!.deathDate;
          _deathDateController.text = DateFormat('dd.MM.yyyy').format(_deathDate!);
        }
      });
    } catch (_) {}
  }

    Future<void> _saveAuthor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final authorData = {
        "firstName": _firstNameController.text,
        "lastName": _lastNameController.text,
        "birthCountry": _birthCountryController.text,
        "birthDate": _birthDate != null ? DateFormat('yyyy-MM-dd').format(_birthDate!) : null,
        "deathDate": _deathDate != null ? DateFormat('yyyy-MM-dd').format(_deathDate!) : null,
        "shortBio": _shortBioController.text,
    };

    if (_author != null && _author!.id > 0) {
        await _authorProvider.updateAuthor(widget.authHeader, _author!.id, authorData);
    } else {
        await _authorProvider.createAuthor(widget.authHeader, authorData);
    }

    setState(() => _isSaving = false);
    Navigator.pop(context, true);
    }


  Future<void> _pickDate(TextEditingController controller, DateTime? initialDate, void Function(DateTime) onPicked) async {
    FocusScope.of(context).requestFocus(FocusNode());
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime(1970),
      firstDate: DateTime(1800),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      onPicked(date);
      controller.text = DateFormat('dd.MM.yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.authorId != null ? "Edit Author" : "Add New Author"),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
            child: Center(
                child: ConstrainedBox(
                 constraints: BoxConstraints(maxWidth: 600),
              child: Container(
                width: MediaQuery.of(context).size.width > 600 ? 600 : double.infinity,
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                  border: Border.all(color: Colors.deepPurple.shade100),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                     TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(labelText: 'First Name', border: OutlineInputBorder()),
                        validator: (v) {
                            if (v == null || v.isEmpty) return 'First name cannot be empty';
                            if (v.length > 50) return 'Maximum 50 characters';
                            return null;
                        },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()),
                        validator: (v) {
                            if (v == null || v.isEmpty) return 'Last name cannot be empty';
                            if (v.length > 50) return 'Maximum 50 characters';
                            return null;
                        },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                        controller: _birthCountryController,
                        decoration: const InputDecoration(labelText: 'Birth Country', border: OutlineInputBorder()),
                        validator: (v) {
                            if (v == null || v.isEmpty) return 'Birth country cannot be empty';
                            if (v.length > 100) return 'Maximum 100 characters';
                            return null;
                        },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                        controller: _birthDateController,
                        decoration: const InputDecoration(labelText: 'Birth Date (dd.MM.yyyy)', border: OutlineInputBorder()),
                        validator: (v) {
                            if (_birthDate == null) return 'Birth date is required';
                            return null;
                        },
                        onTap: () => _pickDate(_birthDateController, _birthDate, (date) => _birthDate = date),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                        controller: _deathDateController,
                        decoration: const InputDecoration(labelText: 'Death Date (optional)', border: OutlineInputBorder()),
                        onTap: () => _pickDate(_deathDateController, _deathDate, (date) => _deathDate = date),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                        controller: _shortBioController,
                        decoration: const InputDecoration(labelText: 'Short Bio', border: OutlineInputBorder()),
                        maxLines: 5,
                        validator: (v) {
                            if (v != null && v.length > 1000) return 'Maximum 1000 characters';
                            return null;
                        },
                        ),

                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveAuthor,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            _isSaving ? "Saving..." : (widget.authorId != null ? "Update Author" : "Add Author"),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ),
          ),
    );
  }
}
