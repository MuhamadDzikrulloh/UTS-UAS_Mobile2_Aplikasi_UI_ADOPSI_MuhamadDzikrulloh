import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final bool isAdmin;
  final String? userEmail;

  const ChatScreen({super.key, this.isAdmin = false, this.userEmail});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textCtrl = TextEditingController();

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  void _send(WidgetRef ref) {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;

    final auth = ref.read(authProvider);
    final currentUserEmail = widget.isAdmin
        ? (widget.userEmail ?? 'unknown')
        : (auth.email ?? 'unknown');

    ref.read(chatProvider.notifier).sendMessage(
          sender: widget.isAdmin ? 'admin' : 'user',
          text: text,
          userEmail: currentUserEmail,
        );
    _textCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final auth = ref.watch(authProvider);
        final chatState = ref.watch(chatProvider);

        final targetEmail = widget.isAdmin
            ? (widget.userEmail ?? 'unknown')
            : (auth.email ?? 'unknown');

        final messages = chatState[targetEmail] ?? [];

        return Scaffold(
          backgroundColor: const Color(0xFFF4F4F4),
          appBar: AppBar(
            title: Text(widget.isAdmin
                ? 'Chat dengan ${widget.userEmail ?? "User"}'
                : 'Chat dengan Admin'),
            backgroundColor: const Color(0xFFFF7A21),
            foregroundColor: Colors.white,
            actions: [
              if (widget.isAdmin)
                IconButton(
                  tooltip: 'Hapus chat ini',
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Hapus Chat?',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600)),
                        content: Text(
                            'Riwayat chat dengan ${widget.userEmail} akan dihapus.',
                            style: GoogleFonts.poppins()),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text('Batal', style: GoogleFonts.poppins()),
                          ),
                          TextButton(
                            onPressed: () {
                              ref
                                  .read(chatProvider.notifier)
                                  .clearUser(targetEmail);
                              Navigator.pop(ctx);
                              Navigator.pop(context);
                            },
                            child: Text('Hapus',
                                style: GoogleFonts.poppins(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (ctx, i) {
                    final msg = messages[i];
                    final isMe = (widget.isAdmin && msg.sender == 'admin') ||
                        (!widget.isAdmin && msg.sender == 'user');
                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              isMe ? const Color(0xFFFF7A21) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Text(
                          msg.text,
                          style: GoogleFonts.poppins(
                              color: isMe ? Colors.white : Colors.black87),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textCtrl,
                        decoration: InputDecoration(
                          hintText: 'Tulis pesan...',
                          hintStyle: GoogleFonts.poppins(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _send(ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7A21),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child:
                          const Icon(Icons.send, color: Colors.white, size: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
