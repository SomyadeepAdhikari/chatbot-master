import 'dart:io';
import 'package:chatbot/backend/saving_data.dart';
import 'package:chatbot/backend/send_message.dart';
import 'package:chatbot/bloc/bloc.dart';
import 'package:chatbot/component/chats_box.dart';
import 'package:chatbot/models/chat_model.dart';
import 'package:chatbot/models/user_model.dart';
import 'package:chatbot/pages/image_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late User user1;
  final User gemini = User(firstName: 'Gemini', userID: '2');
  bool isWriting = false;
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  List<ChatModel> textMessages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: _modernAppBar(context),
      ),
      backgroundColor: const Color(0xFF232526),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF232526), Color(0xFF414345)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<MessageBloc, MessageState>(
                  builder: (context, state) {
                    if (state is InitialState) {
                      user1 = creatingUser();
                      textMessages = deStructure(user1, gemini);
                      return _modernChatList();
                    } else if (state is SendingState) {
                      saveData(textMessages);
                      return _modernChatList();
                    } else if (state is RecievingState) {
                      ChatModel chatModel = ChatModel(
                        text: 'text',
                        user: gemini,
                        createAt: DateTime.now(),
                        isWaiting: true,
                        isSender: false,
                      );
                      textMessages.add(chatModel);
                      return _modernChatList();
                    } else {
                      if (textMessages.length > 2) {
                        textMessages.removeAt(textMessages.length - 2);
                        saveData(textMessages);
                      }
                      return _modernChatList();
                    }
                  },
                ),
              ),
              _modernMessageInput(context),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF667eea),
        child: const Icon(Icons.arrow_downward, color: Colors.white),
        onPressed: () {
          scrollFun(_scroll);
        },
      ),
    );
  }

  Widget _modernChatList() {
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      itemCount: textMessages.length,
      itemBuilder: (context, index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: ChatBox(chatModel: textMessages[index]),
        );
      },
    );
  }

  Widget _modernMessageInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(30),
        color: Colors.white,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.image, color: Color(0xFF667eea)),
              onPressed: () async {
                var contextLocal = Navigator.of(context);
                FilePickerResult? result =
                    await FilePicker.platform.pickFiles();
                if (result != null) {
                  File file = File(result.files.single.path!);
                  contextLocal.push(MaterialPageRoute(
                    builder: ((context) => ImagePage(
                          file: file,
                          buttonFunction: () async {
                            final blocContext =
                                BlocProvider.of<MessageBloc>(context);
                            if (_controller.text.trim().isNotEmpty &&
                                !isWriting) {
                              Navigator.pop(context);
                              isWriting = true;
                              ChatModel message = ChatModel(
                                createAt: DateTime.now(),
                                text: _controller.text.trim(),
                                user: user1,
                                file: file,
                              );
                              _controller.clear();
                              textMessages.add(message);
                              BlocProvider.of<MessageBloc>(context)
                                  .add(DataSent());
                              BlocProvider.of<MessageBloc>(context)
                                  .add(Pending());
                              textMessages
                                  .add(await sendImageData(message, gemini));
                              blocContext.add(DataRecieving());
                            }
                            isWriting = false;
                          },
                          controller: _controller,
                        )),
                  ));
                }
              },
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: "Type a message...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                ),
                minLines: 1,
                maxLines: 4,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 32),
              tooltip: 'Send',
              color: const Color(0xFF667eea),
              padding: const EdgeInsets.all(8),
              style: ButtonStyle(
                backgroundColor:
                    WidgetStatePropertyAll(const Color(0xFF667eea)),
                shape: WidgetStatePropertyAll(const CircleBorder()),
                elevation: WidgetStatePropertyAll(4),
              ),
              onPressed: () async {
                final blocContext = BlocProvider.of<MessageBloc>(context);
                if (_controller.text.trim().isNotEmpty && !isWriting) {
                  isWriting = true;
                  ChatModel message = ChatModel(
                    createAt: DateTime.now(),
                    text: _controller.text.trim(),
                    user: user1,
                  );
                  _controller.clear();
                  textMessages.add(message);
                  BlocProvider.of<MessageBloc>(context).add(DataSent());
                  BlocProvider.of<MessageBloc>(context).add(Pending());
                  textMessages.add(await getdata(message, gemini));
                  blocContext.add(DataRecieving());
                }
                isWriting = false;
              },
            ),
          ],
        ),
      ),
    );
  }

  AppBar _modernAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      title: const Row(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage('assets/gemini.png'),
            radius: 22,
          ),
          SizedBox(width: 12),
          Text(
            "Gemini Chat",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

scrollFun(ScrollController scrollController) {
  scrollController.animateTo(scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
}
