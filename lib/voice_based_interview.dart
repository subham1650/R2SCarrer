import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:r2scareer/interview.dart';
import 'package:record/record.dart';

class VoiceBasedInterviewPage extends StatefulWidget {
  final List<String> skills;
  final String userId;

  const VoiceBasedInterviewPage({
    Key? key,
    required this.skills,
    required this.userId, required Map<String, int> proficiencies,
  }) : super(key: key);

  @override
  State<VoiceBasedInterviewPage> createState() =>
      _VoiceBasedInterviewPageState();
}

class _VoiceBasedInterviewPageState extends State<VoiceBasedInterviewPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isRecording = false;
  bool _isLoading = false;
  Duration _currentRecordingDuration = Duration.zero;
  Timer? _recordingTimer;
  int _questionCount = 0;
  bool _interviewComplete = false;
  List<String> _userAnswers = [];
  List<String> _askedQuestions = [];

  final List<ChatMessage> _messages = [];
  final String _apiKey = 'AIzaSyCxV8rOYgB3vojVaD0V7fkPJulniZ_3-1s';
  final String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    _startInterview();
  }

  Future<void> _initAudioPlayer() async {
    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {});
    });
  }

  Future<void> _startInterview() async {
    setState(() => _isLoading = true);

    final prompt = '''
    Generate exactly 5 concise technical interview questions covering these topics: ${widget.skills.join(', ')}.
    Each question should be 1-2 sentences maximum.
    Questions should cover all mentioned skills and progress in difficulty.
    Output only the questions, one per line, without any numbering or additional text.
    Ensure no question repetition.
    ''';

    try {
      final response = await _sendMessageToGemini(prompt);
      final questions =
          response.split('\n').where((q) => q.trim().isNotEmpty).toList();

      if (questions.isNotEmpty) {
        _addMessage(questions[0], isUser: false);
        _askedQuestions.add(questions[0]);
        _questionCount = 1;
      }
    } catch (e) {
      _addMessage("Error starting interview: $e", isUser: false);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String> _sendMessageToGemini(String message) async {
    final headers = {'Content-Type': 'application/json'};

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": message},
          ],
        },
      ],
    });

    final response = await http.post(
      Uri.parse('$_apiUrl?key=$_apiKey'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'] ??
          "I didn't understand that.";
    } else {
      throw Exception(
        'Failed to get response from Gemini API: ${response.statusCode}',
      );
    }
  }

  void _addMessage(
    String text, {
    required bool isUser,
    String? audioPath,
  }) {
    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: isUser,
          audioPath: audioPath,
          duration: _currentRecordingDuration,
          timestamp: DateTime.now(),
        ),
      );
      _scrollToBottom();
      
      // Auto-play the audio if it's a voice message
      if (audioPath != null) {
        _playAudio(audioPath);
      }
    });
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        setState(() {
          _isRecording = true;
          _currentRecordingDuration = Duration.zero;
        });

        _recordingTimer?.cancel();
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _currentRecordingDuration += const Duration(seconds: 1);
          });
        });

        final tempDir = await getTemporaryDirectory();
        final path =
            '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(const RecordConfig(), path: path);
      }
    } catch (e) {
      debugPrint("Recording error: $e");
      setState(() => _isRecording = false);
    }
  }

  Future<void> _stopRecording() async {
    try {
      _recordingTimer?.cancel();
      final path = await _audioRecorder.stop();

      setState(() {
        _isRecording = false;
      });

      _userAnswers.add("[Voice answer to Q$_questionCount]");
      _addMessage(
        "Voice message",
        isUser: true,
        audioPath: path,
      );
      _askNextQuestion();
    } catch (e) {
      debugPrint("Stop recording error: $e");
      setState(() => _isRecording = false);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Future<void> _askNextQuestion() async {
    if (_questionCount >= 5) {
      await _completeInterview();
      return;
    }

    setState(() => _isLoading = true);

    final prompt = '''
    Generate exactly 1 concise technical question about ${widget.skills.join(', ')}.
    This is question ${_questionCount + 1} of 5.
    Keep it to 1-2 sentences maximum.
    Make it more difficult than previous ones.
    Cover a different skill than previous questions if possible.
    Already asked: ${_askedQuestions.join(' | ')}
    ''';

    try {
      final response = await _sendMessageToGemini(prompt);
      _addMessage(response, isUser: false);
      _askedQuestions.add(response);
      _questionCount++;
    } catch (e) {
      _addMessage("Error getting next question: $e", isUser: false);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _completeInterview() async {
    setState(() => _isLoading = true);
    _interviewComplete = true;

    final prompt = '''
    Provide concise technical feedback on these answers about ${widget.skills.join(', ')}.
    Answers given: ${_userAnswers.join(' | ')}
    Focus on technical accuracy.
    Provide both strengths and areas for improvement.
    Limit to 5-6 sentences maximum.
    ''';

    try {
      final response = await _sendMessageToGemini(prompt);
      _addMessage("Interview complete! Here's your feedback:", isUser: false);
      _addMessage(response, isUser: false);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Interview Completed"),
            content: SingleChildScrollView(child: Text(response)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SkillSelectionPage()),
                  );
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      _addMessage("Error generating feedback: $e", isUser: false);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _playAudio(String? path) async {
    if (path == null) return;
    try {
      if (_audioPlayer.state == PlayerState.playing) {
        await _audioPlayer.stop();
      }
      await _audioPlayer.play(DeviceFileSource(path));
      setState(() {});
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  Future<void> _pauseAudio() async {
    try {
      await _audioPlayer.pause();
      setState(() {});
    } catch (e) {
      debugPrint("Error pausing audio: $e");
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'AI Chat Interview',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(
                  message: message,
                  audioPlayer: _audioPlayer,
                  onPlayAudio: _playAudio,
                  onPauseAudio: _pauseAudio,
                );
              },
            ),
          ),
          if (_isLoading)
            const LinearProgressIndicator(
              backgroundColor: Colors.deepPurpleAccent,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: Colors.white,
            child: Row(
              children: [
                if (!_isRecording && !_interviewComplete)
                  IconButton(
                    icon: const Icon(Icons.mic, color: Colors.deepPurple),
                    onPressed: _startRecording,
                  ),
                if (_isRecording)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _audioRecorder.stop();
                              setState(() => _isRecording = false);
                            },
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Recording...",
                                    style: TextStyle(color: Colors.red)),
                                Text(
                                  _formatDuration(_currentRecordingDuration),
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.stop, color: Colors.green),
                            onPressed: _stopRecording,
                          ),
                        ],
                      ),
                    ),
                  ),
                if (!_isRecording)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: _interviewComplete
                            ? Colors.grey[100]
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              enabled: !_interviewComplete,
                              decoration: InputDecoration(
                                hintText: _interviewComplete
                                    ? "Interview completed"
                                    : "Type a message",
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                              ),
                            ),
                          ),
                          if (!_interviewComplete)
                            IconButton(
                              icon: const Icon(
                                Icons.send,
                                color: Colors.deepPurple,
                              ),
                              onPressed: () async {
                                if (_textController.text.trim().isEmpty) return;

                                final text = _textController.text;
                                _textController.clear();
                                _userAnswers.add(text);
                                _addMessage(text, isUser: true);
                                _askNextQuestion();
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final String? audioPath;
  final Duration duration;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.audioPath,
    required this.duration,
    required this.timestamp,
  });
}

class ChatBubble extends StatefulWidget {
  final ChatMessage message;
  final AudioPlayer audioPlayer;
  final Function(String?) onPlayAudio;
  final Function() onPauseAudio;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.audioPlayer,
    required this.onPlayAudio,
    required this.onPauseAudio,
  }) : super(key: key);

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  bool _isPlaying = false;
  late Stream<PlayerState> _playerStateStream;

  @override
  void initState() {
    super.initState();
    _playerStateStream = widget.audioPlayer.onPlayerStateChanged;
    _playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment:
            widget.message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!widget.message.isUser)
            const CircleAvatar(
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.person, color: Colors.white),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.message.isUser
                    ? Colors.deepPurple[100]
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.message.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        widget.message.text,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  if (widget.message.audioPath != null)
                    _buildAudioPlayer(),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(widget.message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.message.isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildAudioPlayer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: widget.message.isUser ? Colors.deepPurple[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.deepPurple,
              size: 24,
            ),
            onPressed: () {
              if (_isPlaying) {
                widget.onPauseAudio();
              } else {
                widget.onPlayAudio(widget.message.audioPath);
              }
            },
          ),
          const SizedBox(width: 8),
          Text(
            _formatDuration(widget.message.duration),
            style: const TextStyle(
              color: Colors.deepPurple,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inMinutes}:$seconds";
  }
}