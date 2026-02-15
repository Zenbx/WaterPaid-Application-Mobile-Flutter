import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../providers/admin_users_provider.dart';
import '../../core/app_theme.dart';
import '../../models/models.dart';
import 'admin_history_screen.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminUsersProvider);
    final colors = Theme.of(context).extension<AppColors>()!;

    final filteredUsers = state.users.where((u) {
      final query = _searchQuery.toLowerCase();
      return u.pseudo.toLowerCase().contains(query) ||
          u.phone.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Users Directory',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.rotateCw),
            onPressed: () => ref.read(adminUsersProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search by Pseudo or Phone',
                prefixIcon: const Icon(LucideIcons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colors.surface,
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(adminUsersProvider.notifier).refresh(),
              child: state.isLoading && state.users.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null && state.users.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            state.error!,
                            style: TextStyle(color: colors.danger),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () =>
                                ref.read(adminUsersProvider.notifier).refresh(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : filteredUsers.isEmpty
                  ? _buildEmptyState(colors)
                  : _buildUserList(filteredUsers, colors),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.users,
            size: 64,
            color: colors.textSecondary.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'No users found'
                : 'No users match your search',
            style: TextStyle(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(List<AdminUserModel> users, AppColors colors) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: users.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = users[index];
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: colors.accent.withOpacity(0.1),
              child: Text(
                user.pseudo[0].toUpperCase(),
                style: TextStyle(
                  color: colors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              user.pseudo,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.phone),
                if (user.email != null)
                  Text(user.email!, style: const TextStyle(fontSize: 12)),
              ],
            ),
            trailing: Text(
              'Joined\n${DateFormat('MMM yyyy').format(user.createdAt)}',
              textAlign: TextAlign.right,
              style: TextStyle(color: colors.textSecondary, fontSize: 10),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminHistoryScreen(
                    targetId: user.userId,
                    title: 'User: ${user.pseudo}',
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
