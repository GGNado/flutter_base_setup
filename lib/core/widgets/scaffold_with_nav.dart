import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavbar extends StatelessWidget {
  // Questo oggetto 'navigationShell' ci viene passato automaticamente dal Router.
  // Contiene la logica per cambiare i Tab.
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavbar({
    required this.navigationShell,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. IL CORPO (Che cambia):
      // Qui GoRouter inietterà Home, Cerca o Profilo in base al tab selezionato.
      body: navigationShell,

      // 2. LA NAVBAR (Che resta fissa):
      bottomNavigationBar: NavigationBar(
        // Chiediamo alla shell quale tab è attivo (0, 1, 2)
        selectedIndex: navigationShell.currentIndex,

        // Configuriamo le icone
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Cerca'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profilo'),
        ],

        // Quando clicchiamo
        onDestinationSelected: (int index) {
          // Questo metodo magico cambia il "Ramo" (Branch) attivo
          navigationShell.goBranch(
            index,
            // Se clicchi sul tab dove sei già, resetta quella pagina (es. torna in cima)
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}