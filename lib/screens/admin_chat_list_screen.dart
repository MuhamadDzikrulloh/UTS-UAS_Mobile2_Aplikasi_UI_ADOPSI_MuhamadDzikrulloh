import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/chat_provider.dart';
import 'chat_screen.dart';

class AdminChatListScreen extends ConsumerWidget {
  const AdminChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider);
    final userEmails = chatState.keys.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: Text(
          'Chat dari User',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFFF7A21),
        foregroundColor: Colors.white,
        actions: [
          if (userEmails.isNotEmpty)
            IconButton(
              tooltip: 'Hapus semua chat',
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Hapus Semua Chat?',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    content: Text(
                        'Semua riwayat chat dengan user akan dihapus.',
                        style: GoogleFonts.poppins()),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('Batal', style: GoogleFonts.poppins()),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(chatProvider.notifier).clearAll();
                          Navigator.pop(ctx);
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
      body: userEmails.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada chat dari user',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: userEmails.length,
              itemBuilder: (context, index) {
                final email = userEmails[index];
                final messages = chatState[email] ?? [];
                final lastMsg =
                    messages.isNotEmpty ? messages.last : null;
                final unreadFromUser = messages
                    .where((m) => m.sender == 'user')
                    .length;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFFF7A21),
                      child: Text(
                        email[0].toUpperCase(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      email,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: lastMsg != null
                        ? Text(
                            lastMsg.text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          )
                        : null,
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (unreadFromUser > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF7A21),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$unreadFromUser',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const SizedBox(height: 4),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            isAdmin: true,
                            userEmail: email,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
