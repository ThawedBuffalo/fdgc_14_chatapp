import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {

  var _messageController = TextEditingController();

  void _submitMessage() {
    final _enteredMessage = _messageController.text;

    if (_enteredMessage.trim().isEmpty) {
      return;
    }

    // submit

    _messageController.clear();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _messageController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: InputDecoration(labelText: 'Send a message'),
            ),
          ),
          IconButton(icon: Icon(Icons.send),
          onPressed: _submitMessage,
          color: Theme.of(context).colorScheme.primary,),
        ],
      ),
    );
  }
}
