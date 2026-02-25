import 'package:flutter/material.dart';
import 'package:flutter_base_setup/features/user/domain/entities/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/user_controller.dart';

class UserList extends ConsumerWidget {
  const UserList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Ascolto lo stato della lista utenti (Loading / Data / Error)
    final userListState = ref.watch(userControllerProvider);

    return userListState.when(
      // CASO 1: CARICAMENTO
      loading: () => const Center(child: CircularProgressIndicator()),

      // CASO 2: ERRORE
      error: (err, stack) => Center(child: Text("Errore: $err")),

      // CASO 3: DATI PRONTI (lista di utenti)
      data: (users) {
        if (users.isEmpty) {
          return const Center(child: Text("Nessun utente trovato"));
        }

        return ListView.builder(
          shrinkWrap: true,
          // FONDAMENTALE perché siamo dentro un'altra Column/ScrollView
          physics: const NeverScrollableScrollPhysics(),
          // Disabilita lo scroll interno, usa quello della pagina
          padding: const EdgeInsets.all(0),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return _buildUserCard(context, user);
          },
        );
      },
    );
  }

  // Ecco come estrarre il widget in un metodo helper privato per pulizia
  Widget _buildUserCard(BuildContext context, UserResponse user) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          // Usa le iniziali dell'utente se non hai l'immagine
          child: Text(
            user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : "?",
            style: const TextStyle(color: Colors.green),
          ),
        ),
        title: Text("${user.firstName} ${user.lastName}"),
        subtitle: Text(user.email),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          context.go("/home/users/detail", extra: user);
        },
      ),
    );
  }
}
