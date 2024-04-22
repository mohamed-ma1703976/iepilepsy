import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../model/message.dart';  // Ensure your model is correctly configured

class CasesPage extends StatefulWidget {
  @override
  _CasesPageState createState() => _CasesPageState();
}

class _CasesPageState extends State<CasesPage> {
  List<ChatMessage> messages = [];
  final TextEditingController _controller = TextEditingController();
  late final GenerativeModel _model;  // Google Generative AI model
  bool _isLoading = false;
  bool _showSuggestions = true;  // Controls visibility of suggestion chips
  List<String> epilepsyQuestions = [
    "What triggers an epilepsy seizure?",
    "What are the treatments for epilepsy?",
    "How is epilepsy diagnosed?",
    "Can you live a normal life with epilepsy?",
    "What first aid should I provide for a seizure?"
  ];

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(model: 'gemini-pro', apiKey: 'AIzaSyCAByXWEeKW4o12Y16h_Qet1tQOK_0wGc0');
    messages.add(ChatMessage(
      text: 'Hello! I am IEpilepsy Assistant here to help you.',
      type: MessageType.received,
    ));
  }

  void _sendMessage(String text) {
    setState(() {
      messages.add(ChatMessage(text: text, type: MessageType.sent));
      _isLoading = true;
      _showSuggestions = false;  // Hide suggestions when a message is sent
    });
    _processMessage(text);
  }

  void _processMessage(String text) {
    if (epilepsyQuestions.contains(text)) {
      handleEpilepsyQuestion(text);
    } else {
      _model.generateContent([Content.text(text)]).then((response) {
        final responseText = response.text ?? "I couldn't find anything on that topic.";
        setState(() {
          messages.add(ChatMessage(text: responseText, type: MessageType.received));
          _isLoading = false;
        });
      }).catchError((error) {
        setState(() {
          messages.add(ChatMessage(
              text: "Sorry, there was a problem fetching the information.",
              type: MessageType.received
          ));
          _isLoading = false;
          debugPrint('Error fetching response: $error');
        });
      });
    }
  }

  void handleEpilepsyQuestion(String question) {
    // Setting loading state
    setState(() {
      _isLoading = true;
    });

    // Call the model to generate an answer for the epilepsy question
    _model.generateContent([Content.text(question)]).then((response) {
      final responseText = response.text ?? "I couldn't find any detailed information on that topic.";
      setState(() {
        messages.add(ChatMessage(text: responseText, type: MessageType.received));
        _isLoading = false;  // Stop the loading state
      });
    }).catchError((error) {
      setState(() {
        messages.add(ChatMessage(text: "Sorry, there was a problem fetching the information.", type: MessageType.received));
        _isLoading = false;  // Stop the loading state
        debugPrint('Error fetching response: $error');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.grey[100],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _showSuggestions ? _buildSuggestionArea() : Container(),
                _buildMessageList(),
                _buildInputArea(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return Expanded(
      child: AnimationLimiter(
        child: ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            return _buildMessageItem(message, index);
          },
        ),
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message, int index) {
    bool isSent = message.type == MessageType.sent;
    return AnimationConfiguration.staggeredList(
      position: index,
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (!isSent)
                  CircleAvatar(
                    backgroundColor: Colors.deepPurple[200],
                    // Using an image as the avatar
                    backgroundImage: AssetImage('assets/logo.png'),
                  ),
                SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: isSent ? Colors.deepPurple[300] : Colors.grey[200],
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: isSent ? Colors.white : Colors.black,
                        fontSize: 16.0,
                      ),
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

  Widget _buildInputArea() {
    return ClayContainer(
      borderRadius: 25,
      depth: 12,
      spread: 5,
      color: Colors.deepPurple[100],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Send a message',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.purple.withOpacity(0.8)),
                ),
                style: TextStyle(color: Colors.purple),  // Default font style
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _sendMessage(value);
                    _controller.clear();
                  }
                },
              ),
            ),
            IconButton(
              icon: Icon(EvaIcons.paperPlaneOutline, color: Colors.purple),
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
    );
  }

  Widget _buildSuggestionArea() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: epilepsyQuestions.map((question) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ActionChip(
            label: Text(question, style: TextStyle(color: Colors.white)),  // Default font style
            backgroundColor: Colors.deepPurple[300],
            onPressed: () {
              _sendMessage(question);
              setState(() {
                _showSuggestions = false;
              });
            },
          ),
        )).toList(),
      ),
    );
  }
}
