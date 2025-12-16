# 📱 Flutter Clean Architecture (Feature-First)

Questo progetto utilizza un'architettura **Feature-First Clean Architecture** basata su **Riverpod 2.0**.
L'obiettivo è mantenere il codice scalabile, testabile e modulare, separando nettamente la logica di business dalla UI e dall'infrastruttura.

---

## 🏗 Architettura e Stack Tecnologico

Il progetto segue il principio della separazione delle responsabilità attraverso tre layer concentrici:

1. **Domain Layer (Puro):** Contiene le Entità e le regole di business. Non dipende da nessuna libreria esterna (no Flutter, no Dio, no JSON).
2. **Data Layer (Infrastruttura):** Gestisce la comunicazione con l'API, il parsing JSON (DTO) e l'implementazione dei Repository.
3. **Presentation Layer (UI):** Contiene i Widget e i Controller (Riverpod) per la gestione dello stato.

### Librerie Chiave

* **State Management & DI:** `flutter_riverpod`
* **Networking:** `dio` (configurato in `core/network`)
* **Routing:** `go_router` (per la navigazione dichiarativa)
* **Code Generation:** `freezed` & `json_serializable` (per modelli immutabili e DTO sicuri)

---

## 📂 Struttura delle Cartelle

La struttura è divisa in **Core** (condiviso) e **Features** (moduli verticali).

```text
lib/
├── core/                     # Codice condiviso da tutta l'app
│   ├── network/              # Client Dio e Interceptor
│   ├── router/               # Configurazione GoRouter
│   ├── theme/                # Stili e Colori
│   └── widgets/              # Widget generici (bottoni, input)
│
├── features/                 # Moduli funzionali (es. Auth, Products, Cart)
│   └── nome_feature/
│       ├── domain/           # LAYER 1: Logica Pura
│       │   ├── entities/     # Oggetti dart puri (User, Product)
│       │   └── repositories/ # Interfacce astratte (contratti)
│       │
│       ├── data/             # LAYER 2: Dati e API
│       │   ├── models/       # DTOs (estendono Entities + fromJson)
│       │   └── repositories/ # Implementazione concreta (chiamate Dio)
│       │
│       └── presentation/     # LAYER 3: UI
│           ├── providers/    # Controller (AsyncNotifier)
│           └── screens/      # Widget (ConsumerWidget)
```

---

## 🚀 Guida Operativa: Come creare una Nuova Feature

Segui questi passaggi ogni volta che devi aggiungere una nuova funzionalità (es. "Ordini").

### 1. Domain Layer (Il "Cosa")
Definisci i dati puri e cosa vuoi fare con essi.

* Crea l'Entità in `domain/entities/order.dart`:
  ```dart
  // Deve essere una classe pura, senza metodi toJson/fromJson
  class Order {
    final String id;
    final double total;
    const Order({required this.id, required this.total});
  }
  ```

* Definisci il Contratto in `domain/repositories/order_repository.dart`:
  ```dart
  abstract class OrderRepository {
    Future<List<Order>> getOrders();
  }
  ```

### 2. Data Layer (Il "Come")
Implementa la connessione al Backend.

* Crea il Modello DTO in `data/models/order_model.dart` usando Freezed:
  ```dart
  // Usa "implements" per collegarlo all'Entità del dominio.
  @freezed
  abstract class OrderModel with _$OrderModel implements Order {
    const OrderModel._();
    const factory OrderModel({
      required String id,
      required double total,
    }) = _OrderModel;

    factory OrderModel.fromJson(Map<String, dynamic> json) => _$OrderModelFromJson(json);
  }
  ```

* **IMPORTANTE:** Esegui il comando di generazione:
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```

* Implementa il Repository in `data/repositories/order_repository_impl.dart`:
    * Deve estendere l'interfaccia `OrderRepository`.
    * Deve usare `Dio` per chiamare l'API.
    * Deve convertire il JSON in `OrderModel` e ritornarlo.

### 3. Presentation Layer (La UI)
Collega i dati alla vista usando Riverpod.

* Crea il Controller in `presentation/providers/order_controller.dart`:
    * Usa `AsyncNotifier` o `FutureProvider`.
    * Chiama il metodo del repository.

* Crea la Schermata in `presentation/screens/order_list_screen.dart`:
    * Usa `ConsumerWidget`.
    * Usa `ref.watch(provider)` per ascoltare lo stato e costruire la UI.

---

## 🛠 Comandi Utili

### Generazione del Codice (Freezed/Json)
Da lanciare ogni volta che modifichi un `Model` o aggiungi `@freezed`:
```bash
dart run build_runner build --delete-conflicting-outputs
```

Per rigenerare continuativamente mentre sviluppi:
```bash
dart run build_runner watch --delete-conflicting-outputs
```

### Pulizia Cache
Se hai errori strani di generazione:
```bash
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

---

## ⚠️ Regole d'Oro (Best Practices)

1. **Dipendenze:** Il *Domain* non deve mai dipendere dal *Data* o dalla *Presentation*. Le frecce puntano sempre verso l'interno (verso il Dominio).
2. **Logica:** Mai mettere chiamate API (`Dio`) dentro i Widget. Usa sempre il Controller -> Repository.
3. **Entity vs Model:** La UI usa solo le `Entity`. Il Repository converte internamente i `Model` (DTO) in `Entity` prima di restituirli.
