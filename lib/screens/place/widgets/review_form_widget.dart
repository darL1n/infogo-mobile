import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/place_provider.dart';
import 'package:flutter/services.dart';

class ReviewFormWidget extends StatefulWidget {
  final int placeId;
  const ReviewFormWidget({super.key, required this.placeId});

  @override
  State<ReviewFormWidget> createState() => _ReviewFormWidgetState();
}

class _ReviewFormWidgetState extends State<ReviewFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  int _rating = 5;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    try {
      await context.read<PlaceProvider>().addReview(
        placeId: widget.placeId,
        rating: _rating,
        comment: _commentController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Спасибо за отзыв!')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      title: const Text(
        'Оставить отзыв',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Оценка', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            Center(
              child: RatingBar.builder(
                initialRating: _rating.toDouble(),
                minRating: 1,
                itemCount: 5,
                itemSize: 36,
                itemPadding: const EdgeInsets.symmetric(horizontal: 6.0),
                unratedColor: Colors.grey.shade300,
                itemBuilder:
                    (context, _) => const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) {
                  setState(() => _rating = rating.toInt());
                },
              ),
            ),
            const SizedBox(height: 20),
            KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (KeyEvent event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.enter &&
                    (HardwareKeyboard.instance.logicalKeysPressed.contains(
                          LogicalKeyboardKey.controlLeft,
                        ) ||
                        HardwareKeyboard.instance.logicalKeysPressed.contains(
                          LogicalKeyboardKey.metaLeft,
                        ))) {
                  _submit();
                }
              },
              child: TextFormField(
                controller: _commentController,
                autofocus: true,
                maxLines: 4,
                minLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Комментарий',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                validator:
                    (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Обязательное поле'
                            : null,
              ),
            ),
          ],
        ),
      ),
      // actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.grey),
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child:
              _isSubmitting
                  ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Отправить'),
        ),
      ],
    );
  }
}
