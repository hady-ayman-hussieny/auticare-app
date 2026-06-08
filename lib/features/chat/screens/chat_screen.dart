import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:auticare/core/theme/app_colors.dart';
import 'package:auticare/data/models/chat_model.dart';
import 'package:auticare/data/models/child.dart';
import 'package:auticare/data/models/user.dart';
import 'package:auticare/data/services/chat_service.dart';
import 'package:auticare/data/services/children_service.dart';
import 'package:auticare/features/auth/logic/auth_provider.dart';
import 'package:auticare/shared/components/app_shell.dart';
import 'package:auticare/shared/widgets/state_widgets.dart';

class ChatScreen extends StatefulWidget {
  final String? initialChatId;
  const ChatScreen({super.key, this.initialChatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatConversationModel> _conversations = [];
  ChatConversationModel? _selectedConversation;
  List<ChatMessageModel> _messages = [];
  List<ChildModel> _childrenList = [];
  
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _loadingChats = true;
  bool _loadingMessages = false;
  bool _sending = false;
  bool _sharingZoom = false;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _loadingChats = true);
    await Future.wait([
      _fetchConversations(),
      _fetchChildren(),
    ]);
    setState(() => _loadingChats = false);

    // If an initial chat ID is provided or default to first
    if (widget.initialChatId != null) {
      final match = _conversations.firstWhere(
        (c) => c.id == widget.initialChatId,
        orElse: () => _conversations.isNotEmpty ? _conversations.first : const ChatConversationModel(id: '', lastUpdated: '', createdAt: ''),
      );
      if (match.id.isNotEmpty) {
        _selectConversation(match);
      }
    } else if (_conversations.isNotEmpty) {
      _selectConversation(_conversations.first);
    }
  }

  Future<void> _fetchConversations() async {
    try {
      final chats = await chatService.getMyChats();
      if (mounted) {
        setState(() {
          _conversations = chats;
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchChildren() async {
    try {
      final list = await childrenService.getChildren();
      if (mounted) {
        setState(() {
          _childrenList = list;
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchMessages() async {
    if (_selectedConversation == null) return;
    try {
      final msgs = await chatService.getMessages(_selectedConversation!.id);
      if (mounted) {
        setState(() {
          _messages = msgs;
        });
        _scrollToBottom();
      }
    } catch (_) {}
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchMessages());
  }

  void _selectConversation(ChatConversationModel conv) {
    setState(() {
      _selectedConversation = conv;
      _messages = [];
      _loadingMessages = true;
    });
    _fetchMessages().then((_) {
      if (mounted) setState(() => _loadingMessages = false);
    });
    _startPolling();
    // Mark as read
    chatService.markChatAsRead(conv.id);
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

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _selectedConversation == null) return;

    setState(() => _sending = true);
    _messageController.clear();

    try {
      final msg = await chatService.sendMessage(_selectedConversation!.id, text);
      if (msg != null && mounted) {
        setState(() {
          _messages.add(msg);
        });
        _scrollToBottom();
        _fetchConversations(); // Refresh last messages list
      }
    } catch (_) {} finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _shareZoomLink() async {
    if (_selectedConversation == null) return;
    setState(() => _sharingZoom = true);

    try {
      final meetingId = 1000000000 + (DateTime.now().millisecondsSinceEpoch % 9000000000);
      final link = 'https://zoom.us/j/$meetingId';
      final msg = await chatService.sendZoomLink(_selectedConversation!.id, link);
      if (msg != null && mounted) {
        setState(() {
          _messages.add(msg);
        });
        _scrollToBottom();
        _fetchConversations();
      }
    } catch (_) {} finally {
      if (mounted) setState(() => _sharingZoom = false);
    }
  }

  String _getChatDisplayName(ChatConversationModel conv, String myName) {
    // Filter participant names that are not the current user
    final otherParticipants = conv.participantNames.entries
        .where((e) => e.value != myName && e.value.toLowerCase() != 'you')
        .map((e) => e.value)
        .toList();
    return otherParticipants.isNotEmpty ? otherParticipants.first : 'Specialist';
  }

  Map<String, dynamic> _getChatDetails(ChatConversationModel conv, String myId) {
    final otherId = conv.participantIds.firstWhere((id) => id != myId, orElse: () => '');
    final otherName = otherId.isNotEmpty ? (conv.participantNames[otherId] ?? 'Parent') : 'Parent';
    
    // Find child associated with this parent
    final child = _childrenList.firstWhere(
      (c) => c.parentId == otherId,
      orElse: () => const ChildModel(
        id: '',
        parentId: '',
        name: 'Patient Name',
        age: 4,
        gender: 'Male',
        dateOfBirth: '',
        createdAt: '',
      ),
    );

    return {
      'parentName': otherName == 'You' ? 'Caregiver' : otherName,
      'child': child,
      'status': child.id.isNotEmpty ? 'Active' : 'Pending',
    };
  }

  String _getChatSpecialty(ChatConversationModel conv, String myName, bool isSpecialist) {
    final name = _getChatDisplayName(conv, myName).toLowerCase();
    if (name.contains('dr.') || name.contains('doctor')) return 'Doctor';
    if (name.contains('therapist') || name.contains('therapy')) return 'Therapist';
    return isSpecialist ? 'Parent Contact' : 'Assigned Care Specialist';
  }

  String _getLastMessageTime(ChatConversationModel conv) {
    if (conv.lastMessage == null) return '';
    try {
      final dt = DateTime.parse(conv.lastMessage!.timestamp);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${dt.day}/${dt.month}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    if (user == null) return const Scaffold(body: Center(child: Text('Not authenticated')));

    final isSpecialist = user.role == 'doctor' || user.role == 'therapist';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppShell(
      title: 'Care Chats',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 850;

          if (isWide) {
            return Row(
              children: [
                // Chat list sidebar
                SizedBox(
                  width: 320,
                  child: _buildChatListSidebar(user, isSpecialist, isDark, theme),
                ),
                const VerticalDivider(width: 1),
                // Chat detail pane
                Expanded(
                  child: _buildChatDetailPane(user, isSpecialist, isDark, theme),
                ),
                // Specialist right sidebar
                if (isSpecialist && _selectedConversation != null) ...[
                  const VerticalDivider(width: 1),
                  SizedBox(
                    width: 280,
                    child: _buildSpecialistSidebar(user, isDark, theme),
                  ),
                ],
              ],
            );
          } else {
            // Mobile navigation flow (if selected, show detail, else show list)
            if (_selectedConversation != null) {
              return PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, _) {
                  if (!didPop) setState(() => _selectedConversation = null);
                },
                child: Scaffold(
                  appBar: AppBar(
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => setState(() => _selectedConversation = null),
                    ),
                    title: Text(_getChatDisplayName(_selectedConversation!, user.name)),
                    actions: [
                      if (isSpecialist)
                        IconButton(
                          icon: const Icon(Icons.video_call),
                          onPressed: _shareZoomLink,
                        ),
                    ],
                  ),
                  body: _buildChatDetailPane(user, isSpecialist, isDark, theme),
                ),
              );
            }
            return _buildChatListSidebar(user, isSpecialist, isDark, theme);
          }
        },
      ),
    );
  }

  // 1. Chat List Sidebar
  Widget _buildChatListSidebar(UserModel user, bool isSpecialist, bool isDark, ThemeData theme) {
    return Container(
      color: isDark ? const Color(0xFF0F172A) : AppColors.slate50,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Care Chats',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.orange100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(color: AppColors.orange500, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _loadingChats
                ? const Center(child: CircularProgressIndicator())
                : _conversations.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.chat_bubble_outline_rounded,
                        message: 'No care chats started yet.',
                      )
                    : ListView.separated(
                        itemCount: _conversations.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final conv = _conversations[i];
                          final isSelected = _selectedConversation?.id == conv.id;
                          final details = _getChatDetails(conv, user.id);
                          final ChildModel child = details['child'];
                          final displayName = isSpecialist ? child.name : _getChatDisplayName(conv, user.name);
                          final specialty = _getChatSpecialty(conv, user.name, isSpecialist);
                          final displaySubtitle = isSpecialist ? 'Parent: ${details['parentName']}' : specialty;

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _selectConversation(conv),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.orange500
                                      : isDark
                                          ? const Color(0xFF1E293B)
                                          : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.transparent
                                        : isDark
                                            ? Colors.white10
                                            : AppColors.slate200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: isSelected ? Colors.white24 : AppColors.orange100,
                                      child: Text(
                                        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'C',
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : AppColors.orange500,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  displayName,
                                                  style: theme.textTheme.bodyMedium?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: isSelected ? Colors.white : null,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Text(
                                                _getLastMessageTime(conv),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: isSelected ? Colors.white70 : AppColors.slate400,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            displaySubtitle,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: isSelected ? Colors.white70 : AppColors.slate500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            conv.lastMessage?.content ?? 'Consultation started',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: isSelected ? Colors.white60 : AppColors.slate400,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // 2. Chat Detail Pane
  Widget _buildChatDetailPane(UserModel user, bool isSpecialist, bool isDark, ThemeData theme) {
    if (_selectedConversation == null) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('💬', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'Select a Care Chat',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a therapist or doctor consultation chat from the sidebar to coordinate your care program.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.slate500, fontSize: 12),
            ),
          ],
        ),
      );
    }

    final details = _getChatDetails(_selectedConversation!, user.id);
    final ChildModel child = details['child'];
    final displayName = isSpecialist ? child.name : _getChatDisplayName(_selectedConversation!, user.name);
    final displaySubtitle = isSpecialist ? 'Parent: ${details['parentName']}' : _getChatSpecialty(_selectedConversation!, user.name, isSpecialist);

    return Column(
      children: [
        // Detail Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : AppColors.slate200)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.orange100,
                    child: Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'C',
                      style: const TextStyle(color: AppColors.orange500, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayName, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text(displaySubtitle, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate500)),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  if (isSpecialist) ...[
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onPressed: _sharingZoom ? null : _shareZoomLink,
                      icon: _sharingZoom
                          ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.video_call, size: 14),
                      label: const Text('Share Zoom Room', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Text('Connected', style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Message stream
        Expanded(
          child: _loadingMessages
              ? const Center(child: CircularProgressIndicator())
              : _messages.isEmpty
                  ? Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(24),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('💬', style: TextStyle(fontSize: 32)),
                          SizedBox(height: 12),
                          Text('Start the conversation', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 6),
                          Text(
                            'Type a message below to coordinate care times and consultations.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.slate500, fontSize: 11),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, i) {
                        final msg = _messages[i];
                        final isOwn = msg.senderId == user.id;
                        final isZoom = msg.messageType == 'zoom-link' || msg.content.contains('zoom.us');

                        if (isZoom) {
                          return _buildZoomMessageCard(msg, isOwn, isDark, theme);
                        }

                        return Align(
                          alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isOwn
                                  ? AppColors.orange500
                                  : isDark
                                      ? const Color(0xFF1E293B)
                                      : AppColors.slate100,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(20),
                                topRight: const Radius.circular(20),
                                bottomLeft: isOwn ? const Radius.circular(20) : const Radius.circular(4),
                                bottomRight: isOwn ? const Radius.circular(4) : const Radius.circular(20),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg.content,
                                  style: TextStyle(
                                    color: isOwn ? Colors.white : (isDark ? Colors.white : AppColors.slate900),
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatTime(msg.timestamp),
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: isOwn ? Colors.white70 : AppColors.slate400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),

        // Message input panel
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: isDark ? Colors.white10 : AppColors.slate200)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: 'Type your message here...',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E293B) : AppColors.slate100,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.orange500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(10),
                ),
                onPressed: _sending ? null : _sendMessage,
                icon: _sending
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_rounded, size: 18),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 3. Zoom Message Card
  Widget _buildZoomMessageCard(ChatMessageModel msg, bool isOwn, bool isDark, ThemeData theme) {
    return Align(
      alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                : [Colors.blue[50]!, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.blue[300]!.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🎥', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Zoom Consultation Invitation',
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Scheduled clinical room',
                      style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate500),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : Colors.blue[100]!.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Hi, please join our developmental consultation room by clicking the button below.',
                style: theme.textTheme.bodySmall?.copyWith(height: 1.3),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 36,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _launchURL(msg.content),
                child: const Text('Join Zoom Meeting', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                _formatTime(msg.timestamp),
                style: const TextStyle(fontSize: 9, color: AppColors.slate400),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. Specialist Right Sidebar
  Widget _buildSpecialistSidebar(UserModel user, bool isDark, ThemeData theme) {
    if (_selectedConversation == null) return const SizedBox.shrink();

    final details = _getChatDetails(_selectedConversation!, user.id);
    final ChildModel child = details['child'];

    return Container(
      color: isDark ? const Color(0xFF0F172A) : AppColors.slate50,
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          Text(
            'Patient Portal Summary',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          
          // Child avatar and details
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.orange100,
                  child: Text(
                    child.name.isNotEmpty ? child.name[0].toUpperCase() : 'P',
                    style: const TextStyle(color: AppColors.orange500, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.orange100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Patient Profile',
                    style: TextStyle(color: AppColors.orange500, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  child.name,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  'Age: ${child.age} yrs · ${child.gender}',
                  style: const TextStyle(color: AppColors.slate500, fontSize: 11),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Parent details
          const Text(
            'Parent Contact',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.slate400, letterSpacing: 0.5),
          ),
          const SizedBox(height: 6),
          Text('Parent: ${details['parentName']}', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          const Text('Role: Parent User', style: TextStyle(fontSize: 11, color: AppColors.slate500)),
          
          const SizedBox(height: 16),
          const Text(
            'Assigned Program',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.slate400, letterSpacing: 0.5),
          ),
          const SizedBox(height: 6),
          const Text('Development & Autism Care Pathway', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),

          // Action buttons
          if (child.id.isNotEmpty) ...[
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.slate300),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => context.go('/treatment-plan/${child.id}'),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('📋 ', style: TextStyle(fontSize: 12)),
                  Text('View Treatment Plan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange500,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => context.go('/${user.role}/patients/${child.id}'),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🔎 ', style: TextStyle(fontSize: 12)),
                  Text('View Patient Profile', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp);
      final hr = dt.hour.toString().padLeft(2, '0');
      final mn = dt.minute.toString().padLeft(2, '0');
      return '$hr:$mn';
    } catch (_) {
      return '';
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
