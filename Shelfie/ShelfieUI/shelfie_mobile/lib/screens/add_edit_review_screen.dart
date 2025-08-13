import 'package:flutter/widgets.dart';
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/book.dart';
import '../models/review.dart';
import '../providers/review_provider.dart';
import '../providers/user_provider.dart';

class AddEditReviewScreen extends StatefulWidget {
  final String authHeader;
  final int bookId;

  AddEditReviewScreen({required this.authHeader, required this.bookId});

  @override
  State<AddEditReviewScreen> createState() => _AddEditReviewScreenState();
}

class _AddEditReviewScreenState extends State<AddEditReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  int _rating = 0;
  TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = true;
  Review? _existingReview;
  final _provider = ReviewProvider();
  final _userProvider = UserProvider();

  @override
  void initState() {
    super.initState();
    _loadExistingReview();
  }

  Future<void> _loadExistingReview() async {
    setState(() {
      _isLoading = true;
    });

    final user = await _userProvider.getCurrentUser(widget.authHeader);
    final reviews = await _provider.getByBookId(widget.authHeader, widget.bookId);

    _existingReview = reviews.firstWhereOrNull((r) => r.userId == user.id);

    if (_existingReview != null) {
      _rating = _existingReview!.rating;
      _descriptionController.text = _existingReview!.description;
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveReview() async {
    final user = await _userProvider.getCurrentUser(widget.authHeader);
    if (!_formKey.currentState!.validate()) return;

    if (_existingReview != null) {
      await _provider.updateReview(
        widget.authHeader,
        _existingReview!.id,
        _rating,
        _descriptionController.text,
      );
    } else {
      await _provider.addReview(
        widget.authHeader,
        {
          "bookId": widget.bookId,
          "userId": user.id,
          "rating": _rating,
          "description": _descriptionController.text,
        },
      );    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: Text('Add / Edit Review'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.deepPurple[50],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _existingReview != null ? 'Edit Your Review' : 'Add a Review',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: Colors.deepPurple[800],
                ),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 24),
              Text(
                'Rating',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.deepPurple[700],
                ),
              ),
              SizedBox(height: 8),
              Center(
                child: RatingBar.builder(
                  initialRating: _rating.toDouble(),
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (rating) => _rating = rating.toInt(),
                ),
              ),

              SizedBox(height: 24),
              TextFormField(
                controller: _descriptionController,
                maxLength: 1000,
                maxLines: 5,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Description',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Enter a description' : null,
              ),
              SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveReview,
              child: Text(_existingReview != null ? 'Update Review' : 'Add Review'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 16),

              if (_existingReview != null)
                ElevatedButton(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Confirm Delete'),
                        content: Text('Are you sure you want to delete your review?'),
                        actions: [
                          TextButton(
                            child: Text('Cancel'),
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                          TextButton(
                            child: Text('Delete', style: TextStyle(color: Colors.red)),
                            onPressed: () => Navigator.of(context).pop(true),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      try {
                        await _provider.delete(widget.authHeader, _existingReview!.id);
                        Navigator.pop(context, true);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error deleting review'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Delete Review'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
