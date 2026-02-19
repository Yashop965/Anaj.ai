import 'package:flutter/material.dart';
import '../logic/rag_service.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ChatBotView extends StatefulWidget {
  @override
  _ChatBotViewState createState() => _ChatBotViewState();
}

class _ChatBotViewState extends State<ChatBotView> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = []; // {sender: 'user'|'bot', text: '...', options: [], followUps: []}
  final RAGService _ragService = RAGService();
  final FlutterTts _flutterTts = FlutterTts();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _ragService.loadKnowledgeBase();
    _addBotMessage("Namaste! Mai Dr. Khet hu. Apni fasal ya bimari ke baare mein puchiye. (Ex: 'Makka ka Ratuwa' ya 'Rice Blast')");
  }

  void _addBotMessage(String text, {List<String>? options, List<String>? followUps}) {
    setState(() {
      _messages.add({
        'sender': 'bot', 
        'text': text,
        'options': options ?? [],
        'followUps': followUps ?? []
      });
    });
    _scrollToBottom();
    _speak(text); 
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add({'sender': 'user', 'text': text});
    });
    _scrollToBottom();
    _processQuery(text);
  }
  
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _speak(String text) async {
    // Stop any previous speech
    await _flutterTts.stop();
    // Configure for Hindi/English mix if possible, or default
    await _flutterTts.setLanguage("hi-IN"); 
    await _flutterTts.speak(text);
  }

  void _processQuery(String query) {
    final RAGResult result = _ragService.search(query);
    _addBotMessage(
      result.answer,
      options: result.options,
      followUps: result.followUps
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dr. Khet (AI Sahayak)"),
        backgroundColor: Colors.green[800],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                bool isUser = msg['sender'] == 'user';
                List<String> options = msg['options'] ?? [];
                List<String> followUps = msg['followUps'] ?? [];

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.green[100] : Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: isUser ? null : Border.all(color: Colors.green.shade200),
                          boxShadow: [
                             BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))
                          ]
                        ),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        child: Text(msg['text'] as String, style: TextStyle(fontSize: 16)),
                      ),
                      
                      // Render Ambiguity Options (Did you mean?)
                      if (!isUser && options.isNotEmpty)
                        Wrap(
                          spacing: 8.0,
                          children: options.map((opt) => ActionChip(
                            label: Text(opt),
                            backgroundColor: Colors.orange[100],
                            onPressed: () => _addUserMessage(opt),
                          )).toList(),
                        ),

                      // Render Follow-up Questions
                      if (!isUser && followUps.isNotEmpty)
                        Wrap(
                          spacing: 8.0,
                          children: followUps.map((q) => ActionChip(
                            avatar: Icon(Icons.help_outline, size: 16),
                            label: Text(q),
                            backgroundColor: Colors.blue[50],
                            onPressed: () => _addUserMessage(q),
                          )).toList(),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Puchiye...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        _addUserMessage(val);
                        _controller.clear();
                      }
                    },
                  ),
                ),
                SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.green[800],
                  child: Icon(Icons.send),
                  onPressed: () {
                     if (_controller.text.trim().isNotEmpty) {
                        _addUserMessage(_controller.text);
                        _controller.clear();
                     }
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
