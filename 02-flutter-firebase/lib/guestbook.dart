import 'dart:async';

import 'package:flutter/material.dart';

import 'guestbook_message.dart';
import 'src/widgets.dart';

class Guestbook extends StatefulWidget {
  const Guestbook({
    super.key,
    required this.addMessage,
    required this.messages,
  });

  final FutureOr<void> Function(String message) addMessage;
  final List<GuestbookMessage> messages;

  @override
  State<Guestbook> createState() => _GuestbookState();
}

class _GuestbookState extends State<Guestbook> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_GuestbookState');
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Leave a message',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your message to continue';
                      }
                      return null;
                    },
                    onFieldSubmitted: (value) async => await submit(),
                  ),
                ),
                const SizedBox(width: 8),
                StyledButton(
                  onPressed: () async => await submit(),
                  child: const Row(
                    children: [
                      Icon(Icons.send),
                      SizedBox(width: 4),
                      Text('SEND'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        for (var message in widget.messages)
          Paragraph('${message.name}: ${message.message}'),
        const SizedBox(height: 8),
      ],
    );
  }

  Future<void> submit() async {
    if (_formKey.currentState!.validate()) {
      await widget.addMessage(_controller.text);
      _controller.clear();
    }
  }
}
