import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  // 1. Dati che ci aspettiamo di ricevere dalla Home
  final String titolo;

  const DetailPage({
    super.key,
    required this.titolo // Obblighiamo chi la chiama a darci il titolo
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar con la freccia "Indietro" automatica ⬅️
      appBar: AppBar(
        title: const Text("Dettaglio"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            Text(
              "Hai cliccato su:",
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              titolo, // Usiamo il dato passato
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}