import 'package:flutter/material.dart';
import '../models/publisher.dart';
import '../providers/publisher_provider.dart';

class AddEditPublisherScreen extends StatefulWidget {
  final String authHeader;
  final int? publisherId;

  const AddEditPublisherScreen({required this.authHeader, this.publisherId, Key? key}) : super(key: key);

  @override
  _AddEditPublisherScreenState createState() => _AddEditPublisherScreenState();
}

class _AddEditPublisherScreenState extends State<AddEditPublisherScreen> {
  final _formKey = GlobalKey<FormState>();
  final PublisherProvider _publisherProvider = PublisherProvider();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _hqController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _yearFoundedController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  Publisher? _publisher;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() => _isLoading = true);
    if (widget.publisherId != null) {
      await _loadPublisher(widget.publisherId!);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadPublisher(int id) async {
    try {
      _publisher = await _publisherProvider.getById(widget.authHeader, id);
      setState(() {
        _nameController.text = _publisher!.name;
        _hqController.text = _publisher!.headquartersLocation;
        _emailController.text = _publisher!.contactEmail;
        _phoneController.text = _publisher!.contactPhone ?? '';
        _yearFoundedController.text = _publisher!.yearFounded.toString();
        _countryController.text = _publisher!.country;
      });
    } catch (_) {}
  }

    Future<void> _savePublisher() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final publisherData = {
      "name": _nameController.text,
      "headquartersLocation": _hqController.text,
      "contactEmail": _emailController.text,
      "contactPhone": _phoneController.text.isNotEmpty ? _phoneController.text : null,
      "yearFounded": int.tryParse(_yearFoundedController.text),
      "country": _countryController.text,
    };

    try {
      if (_publisher != null && _publisher!.id > 0) {
        await _publisherProvider.updatePublisher(widget.authHeader, _publisher!.id, publisherData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Publisher updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await _publisherProvider.createPublisher(widget.authHeader, publisherData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Publisher added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      Navigator.pop(context, true);
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
    } finally {
      setState(() => _isSaving = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.publisherId != null ? "Edit Publisher" : "Add New Publisher"),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Container(
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
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Name cannot be empty';
                              if (v.length > 100) return 'Maximum 100 characters';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _hqController,
                            decoration: const InputDecoration(labelText: 'HQ Location', border: OutlineInputBorder()),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'HQ location cannot be empty';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(labelText: 'Contact Email', border: OutlineInputBorder()),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Email cannot be empty';
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'Invalid email format';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(labelText: 'Contact Phone (optional)', border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _yearFoundedController,
                            decoration: const InputDecoration(labelText: 'Year Founded', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Year founded is required';
                              final year = int.tryParse(v);
                              if (year == null || year < 1400 || year > DateTime.now().year) return 'Invalid year';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _countryController,
                            decoration: const InputDecoration(labelText: 'Country', border: OutlineInputBorder()),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Country cannot be empty';
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _savePublisher,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                _isSaving ? "Saving..." : (widget.publisherId != null ? "Update Publisher" : "Add Publisher"),
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
