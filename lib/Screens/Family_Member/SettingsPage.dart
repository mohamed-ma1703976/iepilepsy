import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

import '../../Model/Message.dart';
// Make sure the path to your Message model is correct

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  List<ChatMessage> messages = [];
  final TextEditingController _controller = TextEditingController();
  final Gemini _gemini = Gemini.instance; // Initialize Gemini

  @override
  void initState() {
    super.initState();
    // Initial help message
    messages.add(ChatMessage(
      text: 'Hello! How can I assist you today?',
      type: MessageType.received,
    ));
  }

  void _sendMessage(String text) {
    setState(() {
      messages.add(ChatMessage(text: text, type: MessageType.sent));
    });
    _processMessage(text);
  }

  void _processMessage(String text) {
    setState(() {
      messages.add(ChatMessage(text: "Let me find some information for you...", type: MessageType.received));
    });

    // Assuming _gemini.chat() is your method of processing the chat
    _gemini.chat([
      Content(parts: [Parts(text: text)], role: 'user'),
    ]).then((response) {
      final responseText = response?.output ?? "I'm sorry, I couldn't find anything relevant.";
      setState(() {
        messages.add(ChatMessage(text: responseText, type: MessageType.received));
      });
    }).catchError((error) {
      setState(() {
        messages.add(ChatMessage(text: "Apologies, there was an issue retrieving the information.", type: MessageType.received));
      });
      print('Error fetching Gemini response: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Color(0xFFf0e6ff),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: AnimationLimiter(
                    child: ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        bool isSent = message.type == MessageType.sent;
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: ClayContainer(
                                borderRadius: 25,
                                depth: 20,
                                spread: 5,
                                color: isSent ? Color(0xFFa78bfa) : Color(0xFFd1baf8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    mainAxisAlignment: isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
                                    children: [
                                      if (!isSent)
                                        CircleAvatar(
                                          backgroundColor: Colors.white,
                                          child: Icon(EvaIcons.questionMarkCircleOutline, color: Color(0xFFa78bfa)),
                                        ),
                                      SizedBox(width: 8),
                                      Flexible(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                          decoration: BoxDecoration(
                                            color: isSent ? Color(0xFF7c4dff) : Color(0xFF9575cd),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            message.text,
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                ClayContainer(
                  borderRadius: 25,
                  depth: 20,
                  spread: 5,
                  color: Color(0xFFd1baf8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: 'Type your message here...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                            ),
                            style: TextStyle(color: Colors.white),
                            onSubmitted: (value) {
                              if (value.isNotEmpty) {
                                _sendMessage(value);
                                _controller.clear();
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(EvaIcons.paperPlaneOutline, color: Colors.white),
                          onPressed: () {
                            if (_controller.text.isNotEmpty) {
                              _sendMessage(_controller.text);
                              _controller.clear();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
