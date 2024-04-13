enum MessageType {
  sent,
  received,
}

class ChatMessage {
  final String text;
  final MessageType type;
  final String? avatar; // Add this line to include the 'avatar' field


  ChatMessage({required this.text, required this.type,this.avatar, // Add this line to include the 'avatar' field
  });
}
