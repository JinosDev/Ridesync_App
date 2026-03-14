import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/ridesync_button.dart';
import '../../../core/widgets/error_banner.dart';

class TripRatingScreen extends ConsumerStatefulWidget {
  final String scheduleId;
  const TripRatingScreen({super.key, required this.scheduleId});
  @override
  ConsumerState<TripRatingScreen> createState() => _TripRatingScreenState();
}

class _TripRatingScreenState extends ConsumerState<TripRatingScreen> {
  int _rating  = 0;
  final _commentCtrl = TextEditingController();
  bool _submitting   = false;

  @override
  void dispose() { _commentCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (_rating == 0) { ErrorBanner.show(context, 'Please select a rating'); return; }
    setState(() => _submitting = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('feedback').add({
        'passengerId': uid,
        'scheduleId':  widget.scheduleId,
        'rating':      _rating,
        'comment':     _commentCtrl.text.trim(),
        'submittedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) { ErrorBanner.showSuccess(context, 'Thank you for your feedback!'); Navigator.of(context).pop(); }
    } catch (e) {
      if (mounted) ErrorBanner.show(context, 'Failed to submit rating: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rate Your Trip')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('How was your trip?', style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: AppDimensions.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) => IconButton(
                onPressed: () => setState(() => _rating = i + 1),
                icon: Icon(i < _rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 40),
              )),
            ),
            const SizedBox(height: AppDimensions.md),
            TextFormField(
              controller: _commentCtrl,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Comments (optional)', alignLabelWithHint: true),
            ),
            const SizedBox(height: AppDimensions.lg),
            RideSyncButton(label: 'Submit Rating', isLoading: _submitting, onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
