import 'dart:io';
import 'dart:ui';
import 'package:chatbot/backend/saving_data.dart';
import 'package:chatbot/backend/send_message.dart';
import 'package:chatbot/bloc/bloc.dart';
import 'package:chatbot/component/chats_box.dart';
import 'package:chatbot/components/modern_widgets.dart';
import 'package:chatbot/main.dart';
import 'package:chatbot/models/chat_model.dart';
import 'package:chatbot/models/user_model.dart';
import 'package:chatbot/pages/image_page.dart';
import 'package:chatbot/theme/app_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage1 extends StatefulWidget {
  const HomePage1({super.key});

  @override
  State<HomePage1> createState() => _HomePage1State();
}

class _HomePage1State extends State<HomePage1> with TickerProviderStateMixin {
  late User user1;
  final User gemini = User(firstName: 'Gemini', userID: '2');
  late List<ChatModel> allMessages;
  late TextEditingController controller;
  late ScrollController scrollController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    scrollController = ScrollController();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _initializeData();
    _startAnimations();
  }

  void _initializeData() async {
    user1 = creatingUser();
    allMessages = deStructure(user1, gemini);
    if (mounted) {
      setState(() {});
      _scrollToBottom();
    }
  }

  void _startAnimations() {
    _fadeController.forward();
    _slideController.forward();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      extendBodyBehindAppBar: true,
      appBar: _buildModernAppBar(context),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surfaceContainerLowest,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Chat messages area
              Expanded(
                child: _buildChatArea(),
              ),
              // Input area
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gemini AI',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                'Smart Assistant',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _showOptionsMenu,
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.more_vert_rounded,
              color: Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildChatArea() {
    return BlocConsumer<MessageBloc, MessageState>(
      listener: (context, state) {
        if (state is RecievingState) {
          _scrollToBottom();
        }
      },
      builder: (context, state) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: allMessages.isEmpty
                  ? _buildEmptyState()
                  : _buildMessagesList(state),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              size: 60,
              color: Colors.white,
            ),
          )
              .animate()
              .scale(delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut)
              .shimmer(delay: 800.ms, duration: 1000.ms),
          const SizedBox(height: 32),
          Text(
            'Welcome to Gemini AI',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 600.ms)
              .slideY(begin: 0.3, end: 0),
          const SizedBox(height: 12),
          Text(
            'Start a conversation and explore the possibilities',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          )
              .animate()
              .fadeIn(delay: 600.ms, duration: 600.ms)
              .slideY(begin: 0.3, end: 0),
          const SizedBox(height: 32),
          _buildSuggestionChips(),
        ],
      ),
    );
  }

  Widget _buildSuggestionChips() {
    final suggestions = [
      'Explain quantum physics',
      'Write a poem',
      'Plan a trip',
      'Solve a problem',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: suggestions.asMap().entries.map((entry) {
        final index = entry.key;
        final suggestion = entry.value;

        return InkWell(
          onTap: () {
            controller.text = suggestion;
            _sendMessage();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              suggestion,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(delay: (800 + index * 100).ms, duration: 600.ms)
            .slideY(begin: 0.3, end: 0);
      }).toList(),
    );
  }

  Widget _buildMessagesList(MessageState state) {
    return AnimationLimiter(
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: allMessages.length +
            (state is SendingState ? 1 : 0) +
            (state is RecievingState ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < allMessages.length) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: ChatsBox(
                    message: allMessages[index],
                    user: allMessages[index].user.userID == user1.userID
                        ? user1
                        : gemini,
                  ),
                ),
              ),
            );
          } else if (state is SendingState && index == allMessages.length) {
            return _buildTypingIndicator(isUser: true);
          } else if (state is RecievingState) {
            return _buildTypingIndicator(isUser: false);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildTypingIndicator({required bool isUser}) {
    return Container(
      margin: EdgeInsets.only(
        left: isUser ? 60 : 16,
        right: isUser ? 16 : 60,
        bottom: 16,
      ),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUser
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...List.generate(3, (index) {
                  return Container(
                    width: 6,
                    height: 6,
                    margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  )
                      .animate(
                        onPlay: (controller) => controller.repeat(),
                      )
                      .scale(
                        duration: 600.ms,
                        delay: (index * 200).ms,
                        curve: Curves.easeInOut,
                      );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Modern floating input container
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  blurRadius: 32,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.9),
                        Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    child: Row(
                      children: [
                        // Attachment button
                        _buildAttachmentButton(),
                        const SizedBox(width: 8),
                        // Text input field
                        Expanded(child: _buildTextInput()),
                        const SizedBox(width: 8),
                        // Voice/Send button
                        _buildActionButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Quick actions
          _buildQuickActions(),
        ],
      ),
    ).animate()
      .slideY(begin: 1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic)
      .fadeIn(duration: 400.ms);
  }

  Widget _buildAttachmentButton() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _pickImage,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Icon(
              Icons.add_photo_alternate_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
        ),
      ),
    ).animate(delay: 200.ms)
      .scale(begin: const Offset(0.8, 0.8), duration: 300.ms, curve: Curves.easeOutBack)
      .fadeIn(duration: 200.ms);
  }

  Widget _buildTextInput() {
    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      child: TextField(
        controller: controller,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Theme.of(context).colorScheme.onSurface,
          height: 1.4,
        ),
        decoration: InputDecoration(
          hintText: 'Ask me anything...',
          hintStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
        ),
        maxLines: null,
        textInputAction: TextInputAction.send,
        onSubmitted: (_) => _sendMessage(),
        cursorColor: Theme.of(context).colorScheme.primary,
        cursorWidth: 2,
        cursorHeight: 20,
      ),
    );
  }

  Widget _buildActionButton() {
    return BlocBuilder<MessageBloc, MessageState>(
      builder: (context, state) {
        final isLoading = state is SendingState || state is RecievingState;
        final hasText = controller.text.trim().isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: Container(
            decoration: BoxDecoration(
              gradient: hasText && !isLoading ? AppTheme.primaryGradient : null,
              color: !hasText || isLoading 
                  ? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                  : null,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: hasText && !isLoading 
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                    : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: hasText && !isLoading ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ] : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isLoading ? null : (hasText ? _sendMessage : _startVoiceInput),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        )
                      : Icon(
                          hasText ? Icons.send_rounded : Icons.mic_rounded,
                          color: hasText && !isLoading 
                              ? Colors.white 
                              : Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                ),
              ),
            ),
          ),
        ).animate(delay: 300.ms)
          .scale(begin: const Offset(0.8, 0.8), duration: 400.ms, curve: Curves.easeOutBack)
          .fadeIn(duration: 300.ms);
      },
    );
  }

  Widget _buildQuickActions() {
    final suggestions = [
      {'icon': Icons.lightbulb_outline_rounded, 'text': 'Ideas'},
      {'icon': Icons.help_outline_rounded, 'text': 'Help'},
      {'icon': Icons.trending_up_rounded, 'text': 'Trends'},
    ];

    return Container(
      margin: const EdgeInsets.only(top: 12),
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showIdeasMenu(suggestion['text'] as String),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        suggestion['icon'] as IconData,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        suggestion['text'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ).animate(delay: Duration(milliseconds: 400 + (index * 100)))
            .slideX(begin: 0.3, duration: 300.ms, curve: Curves.easeOutCubic)
            .fadeIn(duration: 200.ms);
        },
      ),
    );
  }

  void _startVoiceInput() {
    // Voice input functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Voice input feature coming soon!',
          style: GoogleFonts.inter(),
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showIdeasMenu(String type) {
    final ideas = {
      'Ideas': [
        'Create a story about...',
        'Explain quantum physics',
        'Plan a weekend trip',
        'Help with coding',
      ],
      'Help': [
        'How to use this app?',
        'What can you do?',
        'Privacy settings',
        'Report an issue',
      ],
      'Trends': [
        'Latest AI developments',
        'Tech trends 2024',
        'Popular topics',
        'News summary',
      ],
    };

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              type,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ...ideas[type]!.map((idea) => ListTile(
              title: Text(
                idea,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              onTap: () {
                controller.text = idea;
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _sendMessage() async {
    if (controller.text.trim().isEmpty) return;

    final userMessage = ChatModel(
      text: controller.text.trim(),
      user: user1,
      createAt: DateTime.now(),
    );

  // Add debugging
  debugPrint('Sending message: ${userMessage.text}');
  debugPrint('API Key length: ${apiKey.length}');
  debugPrint('API Key starts with: ${apiKey.substring(0, 10)}...');

    context.read<MessageBloc>().add(DataSent());

    setState(() {
      allMessages.add(userMessage);
    });

    controller.clear();
    _scrollToBottom();

    // Get AI response
    try {
      context.read<MessageBloc>().add(Pending());
      
      // Try the primary method first
      ChatModel aiResponse;
      try {
  aiResponse = await getdata(userMessage, gemini);
  if (!mounted) return;
      } catch (e) {
  // If primary method fails, try HTTP fallback
  debugPrint('Primary method failed, trying HTTP fallback: $e');
  aiResponse = await getdataHttp(userMessage, gemini);
  if (!mounted) return;
      }
      
      context.read<MessageBloc>().add(DataRecieving());
      
      setState(() {
        allMessages.add(aiResponse);
      });
      
      _scrollToBottom();
    } catch (e) {
  debugPrint('All methods failed: $e');
      context.read<MessageBloc>().add(DataRecieving());
      
      final errorMessage = ChatModel(
        text: 'Sorry, I encountered an error. Please check your internet connection and try again.',
        user: gemini,
        createAt: DateTime.now(),
        isSender: false,
      );
      
      setState(() {
        allMessages.add(errorMessage);
      });
      
      _scrollToBottom();
    }
  }

  void _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final imageController = TextEditingController();

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImagePage(
                file: file,
                buttonFunction: () => _sendImageMessage(file, imageController),
                controller: imageController,
              ),
            ),
          );
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: $e');
    }
  }

  void _sendImageMessage(File imageFile, TextEditingController imageController) async {
    if (imageController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a message with your image');
      return;
    }

    final userMessage = ChatModel(
      text: imageController.text.trim(),
      user: user1,
      createAt: DateTime.now(),
      file: imageFile,
    );

    context.read<MessageBloc>().add(DataSent());

    setState(() {
      allMessages.add(userMessage);
    });

    imageController.clear();
    Navigator.pop(context); // Close the image page
    _scrollToBottom();

    // Get AI response for image
    try {
      context.read<MessageBloc>().add(Pending());
      
  final aiResponse = await sendImageData(userMessage, gemini);
  if (!mounted) return;
      
      context.read<MessageBloc>().add(DataRecieving());
      
      setState(() {
        allMessages.add(aiResponse);
      });
      
      _scrollToBottom();
    } catch (e) {
      context.read<MessageBloc>().add(DataRecieving());
      
      final errorMessage = ChatModel(
        text: 'Sorry, I encountered an error processing your image. Please try again.',
        user: gemini,
        createAt: DateTime.now(),
        isSender: false,
      );
      
      setState(() {
        allMessages.add(errorMessage);
      });
      
      _scrollToBottom();
    }
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassContainer(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.refresh_rounded),
                title: const Text('Clear Chat'),
                onTap: _clearChat,
              ),
              ListTile(
                leading: const Icon(Icons.settings_rounded),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  // Add settings navigation
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text('About'),
                onTap: () {
                  Navigator.pop(context);
                  _showAboutDialog();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearChat() {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to clear all messages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                allMessages.clear();
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Gemini AI'),
        content: const Text(
            'A modern AI chat application powered by Google Gemini.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
