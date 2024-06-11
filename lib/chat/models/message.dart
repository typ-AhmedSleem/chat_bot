class Message {

  final String content;
  final bool isMe;
  final String timestamp;

  Message({required this.content, required this.isMe, required this.timestamp});

  static Message defaultMessage() {
    return Message(content: "السلام عليكم! اخبرني ما الذي تريده ؟", isMe: false, timestamp: "NOT YET IMPLEMENTED");
  }

}