# Feature-First Clean Architecture (Riverpod 2.0)

Questo progetto è un'applicazione Flutter scalabile e professionale, progettata seguendo rigorosamente la **Feature-First Clean Architecture**. L'obiettivo è garantire modularità, testabilità e manutenibilità, separando nettamente la logica di business dall'interfaccia utente e dall'infrastruttura.

## 1. Project Overview

Questa applicazione è stata strutturata per essere modulare. Invece di raggruppare i file per "tipo" (tutti i controller insieme, tutte le schermate insieme), il codice è organizzato per **Feature** (funzionalità). Ogni feature è un modulo autonomo che contiene tutto il necessario per funzionare (Dominio, Dati e UI), facilitando lo sviluppo parallelo e la scalabilità del progetto.

## 2. Tech Stack

Le librerie chiave utilizzate in questo progetto sono:

- **State Management:** `flutter_riverpod` (v2.0+)
    - Utilizzo estensivo di `AsyncNotifier` e `Provider` per la gestione reattiva dello stato.
- **Network:** `dio`
    - Configurazione centralizzata con interceptors per la gestione degli errori e dei token.
- **Data Class / JSON:** `freezed` & `json_serializable`
    - Per la generazione di classi immutabili, unioni discriminate (sealed classes) e serializzazione JSON sicura.
- **Navigation:** `go_router`
    - Gestione del routing dichiarativo e deep linking.
- **Architecture:** Feature-First Clean Architecture.

## 3. Architecture & Folder Structure

La struttura ad alto livello divide il codice in `core` (condiviso) e `features` (specifico).

```text
lib/
├── core/                       # Componenti condivisi (Network Client, Router, Theme, Utils)
└── features/                   # Moduli funzionali
    └── nome_feature/           # Es. "orders", "auth", "products"
        ├── domain/             # LAYER 1: Business Logic (Puro Dart)
        │   ├── entities/       # Oggetti di business
        │   └── repositories/   # Interfacce dei Repository
        │
        ├── data/               # LAYER 2: Infrastruttura (Impl. & JSON)
        │   ├── models/         # DTOs (Data Transfer Objects)
        │   └── repositories/   # Implementazione dei Repository
        │
        └── presentation/       # LAYER 3: Interfaccia Utente (UI & State)
            ├── providers/      # Riverpod Controllers
            └── screens/        # Widgets
```

### Dettaglio dei 3 Layer (per ogni Feature)

1.  **Domain Layer (Il Cuore):**
    *   Scritto in **Puro Dart**. Nessuna dipendenza da Flutter, Dio o librerie di serializzazione.
    *   Contiene le **Entities** (i dati come servono all'app) e le **Repository Interfaces** (contratti astratti per il recupero dati).

2.  **Data Layer (L'Adattatore):**
    *   Gestisce l'infrastruttura e la comunicazione con l'esterno.
    *   Contiene i **Models/DTOs** (che estendono le Entities e gestiscono `fromJson`/`toJson`) e le **Repository Implementations** (che usano Dio per chiamare le API).

3.  **Presentation Layer (La UI):**
    *   Gestisce ciò che l'utente vede.
    *   Contiene i **Riverpod Providers** (Controllers che gestiscono lo stato della UI) e i **ConsumerWidgets** (Schermate che reagiscono allo stato).

## 4. Guide: How to Add a New Feature

Segui questa guida passo-passo per aggiungere una nuova funzionalità (esempio: "Orders").

### Step 1: Domain (Definisci il problema)
Inizia sempre dal dominio. Definisci cosa sono i dati e cosa puoi fare con essi.
1.  Crea l'**Entity** (classe pura): `class Order { ... }`.
2.  Definisci la **Repository Interface**: `abstract class OrderRepository { Future<List<Order>> getOrders(); }`.

### Step 2: Data (Implementa la soluzione)
Collega il dominio al backend.
1.  Crea il **DTO** usando `@freezed`: `class OrderDto with _$OrderDto implements Order { ... }`.
2.  Esegui il generatore: `dart run build_runner build --delete-conflicting-outputs`.
3.  Implementa la Repository: `class OrderRepositoryImpl implements OrderRepository { ... }`. Usa `dio` per fare la richiesta e restituisci le Entities (convertendo i DTO).

### Step 3: Presentation (Mostra il risultato)
Collega i dati all'utente.
1.  Crea il **Controller** (Provider): `class OrderListController extends AsyncNotifier<List<Order>> { ... }`.
2.  Crea la **Screen**: `class OrderScreen extends ConsumerWidget { ... }`. Usa `ref.watch(orderListControllerProvider)` per mostrare caricamento, errore o lista ordini.

## 5. Development Commands

Comandi essenziali per lavorare sul progetto:

### Eseguire l'applicazione
```bash
flutter run
```

### Generare il codice (Freezed & JSON)
Da eseguire ogni volta che si modificano modelli annotati con `@freezed` o `@JsonSerializable`.
```bash
dart run build_runner build --delete-conflicting-outputs
```

Per mantenere il generatore in ascolto durante lo sviluppo:
```bash
dart run build_runner watch --delete-conflicting-outputs
```

## 6. Best Practices / Rules

Segui queste regole per mantenere il codice pulito e l'architettura solida:

- **DO:** Usa `ref.watch` all'interno del metodo `build()` dei widget. Questo assicura che il widget si ricostruisca automaticamente quando lo stato cambia.
- **DO:** Usa `ref.read` all'interno dei callback (es. `onPressed`, `onTap`). Non usare `watch` nei callback.
- **DON'T:** Non inserire **MAI** chiamate API (Dio) direttamente nei Widget. La UI deve essere stupida; deve solo chiamare metodi del Controller.
- **DON'T:** Non permettere al **Domain Layer** di conoscere dettagli di implementazione come JSON, annotazioni di serializzazione o il package `dio`. Il dominio deve rimanere puro.
