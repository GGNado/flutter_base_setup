import 'package:flutter/material.dart';
import 'package:flutter_base_setup/features/user/domain/entities/user.dart';

class DetailPage extends StatelessWidget {
  // 1. Dati che ci aspettiamo di ricevere dalla Home
  final UserResponse userResponse;

  const DetailPage({
    super.key,
    required this.userResponse, // Obblighiamo chi la chiama a darci il titolo
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dettaglio utente Selezionato")),
      body: Column(
        // Rimosso MainAxisAlignment.center per lasciare la Card in alto
        children: [
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.3),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nome: ${userResponse.firstName}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Cognome: ${userResponse.lastName}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // AVATAR
                Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: const NetworkImage(
                        "https://cdn-icons-png.flaticon.com/512/6325/6325109.png",
                      ),
                    ),
                  ],
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Email ${userResponse.email}"),
                    Text("ID ${userResponse.id}"),
                  ],
                ),
              ],
            ),
          ),
          
          // EXPANDED: Occupa tutto lo spazio rimanente sotto la card
          Expanded(
            child: Center(
              // CENTER: Centra il bottone dentro lo spazio rimanente
              child: ElevatedButton.icon(
                onPressed: () {},
                label: const Text("CIAO"),
                icon: const Icon(Icons.waving_hand),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
