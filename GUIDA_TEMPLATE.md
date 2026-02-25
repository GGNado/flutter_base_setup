# 🚀 GUIDA AL TEMPLATE — Flutter Base Setup

Questa guida è pensata per chi è **alle prime armi con Riverpod** e vuole capire come funziona questo template. Leggi tutto con calma, ogni sezione è spiegata passo-passo.

---

## 📑 Indice

1. [Cos'è Riverpod](#1--cosè-riverpod)
2. [Struttura del Progetto](#2--struttura-del-progetto)
3. [Il Flusso di Autenticazione (Splash Screen)](#3--il-flusso-di-autenticazione)
4. [Riverpod: Le Regole d'Oro](#4--riverpod-le-regole-doro)
5. [GoRouter e Navigazione](#5--gorouter-e-navigazione)
6. [Come Aggiungere una Nuova Feature](#6--come-aggiungere-una-nuova-feature)
7. [Pattern Comuni](#7--pattern-comuni)
8. [Comandi Utili](#8--comandi-utili)
9. [FAQ — Domande Frequenti](#9--faq--domande-frequenti)

---

## 1. 🧩 Cos'è Riverpod

Riverpod è il sistema di **state management** di questo template. In parole semplici:

> **Un Provider è un "contenitore" di stato che tutta l'app può leggere e ascoltare.**

### I tipi di Provider che usiamo

| Tipo | Quando usarlo | Esempio nel progetto |
|---|---|---|
| `Provider<T>` | Oggetti che non cambiano mai (Dio, Repository) | `dioProvider`, `authRepositoryProvider` |
| `AsyncNotifierProvider<N, T>` | Stato che viene da una chiamata async (API) e può cambiare | `authControllerProvider`, `userControllerProvider` |

### AsyncNotifier — Il cuore dello stato

Un `AsyncNotifier` è una classe che:
1. Ha un metodo `build()` che viene chiamato automaticamente all'avvio
2. Ritorna un `Future<T>` — Riverpod lo trasforma in `AsyncValue<T>`
3. `AsyncValue` ha 3 stati: **loading**, **data**, **error**

```dart
// Esempio: AuthController
class AuthController extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    // Questo codice viene eseguito automaticamente!
    // Riverpod gestisce loading/error per te.
    final user = await verificaToken();
    return user; // → AsyncData(user)
  }
}
```

### `ref` — Il collegamento tra Provider

`ref` è l'oggetto che permette ai provider di comunicare tra loro:

```dart
// DENTRO un Provider o Notifier:
final dio = ref.read(dioProvider);        // Legge UNA volta
final user = ref.watch(altroProvider);    // Ascolta i cambiamenti
```

---

## 2. 📁 Struttura del Progetto

```
lib/
├── main.dart                    ← Entry point
├── app.dart                     ← MaterialApp con il Router
│
├── core/                        ← Componenti CONDIVISI (usati da tutte le feature)
│   ├── network/
│   │   └── dio_provider.dart    ← Client HTTP configurato (con interceptor per il token)
│   ├── router/
│   │   └── router_provider.dart ← Tutte le rotte dell'app e redirect/guard
│   ├── storage/
│   │   └── shared_prefs_provider.dart ← Provider di SharedPreferences
│   └── widgets/
│       ├── app_text_field.dart   ← TextField riutilizzabile
│       └── scaffold_with_nav.dart ← Scaffold con la BottomNavigationBar
│
└── features/                    ← Una cartella per ogni FUNZIONALITÀ
    ├── auth/                    ← Feature: Autenticazione
    │   ├── domain/              ← LAYER 1: Business Logic (Dart puro)
    │   │   ├── entities/user.dart        ← "Cos'è un User?" (interfaccia)
    │   │   └── repositories/auth_repository.dart ← "Cosa posso fare?" (contratto)
    │   ├── data/                ← LAYER 2: Implementazione
    │   │   ├── models/user_model.dart    ← "Come è fatto il JSON?" (DTO con Freezed)
    │   │   ├── datasource/auth_local_data_source.dart ← Salvataggio locale
    │   │   └── repositories/auth_repository_impl.dart ← Chiamate API reali
    │   └── presentation/        ← LAYER 3: UI
    │       ├── providers/auth_controller.dart ← Logica dello stato
    │       ├── screens/splash_screen.dart     ← Splash + verifica token
    │       ├── screens/login_screen.dart      ← Form di login
    │       └── widget/                        ← Widget riutilizzabili
    │
    ├── home/                    ← Feature: Dashboard
    └── user/                    ← Feature: Lista utenti (esempio)
```

### Perché 3 Layer?

```
┌─────────────────────────────────────────────────┐
│  PRESENTATION (UI)                              │
│  "Come lo mostro all'utente?"                   │
│  → ConsumerWidget, Controller, Screen           │
│  → DIPENDE DAL DOMAIN                           │
├─────────────────────────────────────────────────┤
│  DOMAIN (Business Logic)                        │
│  "Cosa sono i miei dati? Cosa posso farci?"     │
│  → Entity (classe astratta), Repository (astratto) │
│  → NON DIPENDE DA NESSUNO (Dart puro!)          │
├─────────────────────────────────────────────────┤
│  DATA (Infrastruttura)                          │
│  "Come li prendo dal server? Come li salvo?"    │
│  → Model (fromJson), Repository Impl (con Dio)  │
│  → DIPENDE DAL DOMAIN (implementa i contratti)  │
└─────────────────────────────────────────────────┘
```

**Regola fondamentale**: il Domain Layer NON importa MAI `dio`, `freezed`, `flutter`, ecc. Deve restare **puro Dart**.

---

## 3. 🔐 Il Flusso di Autenticazione

Questo è il cuore del template. Ecco cosa succede quando l'app si apre:

```
 ┌──────────────────────────┐
 │      APP SI APRE         │
 │   → Splash Screen (/)    │
 └────────────┬─────────────┘
              │
              ▼
 ┌──────────────────────────┐
 │  AuthController.build()  │
 │  Controlla SharedPrefs   │
 └────────────┬─────────────┘
              │
     ┌────────┴────────┐
     │                 │
     ▼                 ▼
 Token NULL        Token PRESENTE
     │                 │
     ▼                 ▼
 return null     Chiama API /validate
 → vai a /login       │
              ┌───────┴───────┐
              │               │
              ▼               ▼
         Risposta OK     Errore 401
         return user     removeUser()
         → vai a /home  return null
                         → vai a /login
              │
              ▼
         Errore di Rete
         rethrow → AsyncError
         → Splash mostra "RIPROVA"
              │
              ▼
         Utente clicca RIPROVA
         → retry() → invalidateSelf()
         → build() riesecuto
```

### Come funziona nel codice

**1. AuthController** (`auth_controller.dart`)
```dart
@override
Future<User?> build() async {
  final user = local.getUser();       // Legge da SharedPrefs
  if (user == null) return null;      // Nessun token → login

  try {
    await repo.isTokenValid(user.token); // Verifica con il backend
    return user;                          // OK → home
  } on DioException catch (e) {
    if (e.response?.statusCode == 401) {
      local.removeUser();
      return null;                        // Token scaduto → login
    }
    rethrow;                              // Errore rete → retry
  }
}
```

**2. SplashScreen** (`splash_screen.dart`)
```dart
// NAVIGAZIONE (side-effect) → ref.listen
ref.listen(authControllerProvider, (_, next) {
  next.whenData((user) {
    if (user != null) context.go('/home');
    else context.go('/login');
  });
});

// UI (visual feedback) → ref.watch
final authState = ref.watch(authControllerProvider);
authState.when(
  loading: () => CircularProgressIndicator(),  // Spinner
  data: (_) => CircularProgressIndicator(),    // In attesa del redirect
  error: (e, _) => RetryButton(),              // Bottone "Riprova"
);
```

**Perché `ref.listen` E `ref.watch`?**
- `ref.listen` → per **side-effects** (navigazione, snackbar). Non causa rebuild.
- `ref.watch` → per **costruire la UI**. Causa rebuild ad ogni cambio di stato.
- Nella splash screen usiamo ENTRAMBI: listen per navigare, watch per mostrare errore/loading.

---

## 4. ⚡ Riverpod: Le Regole d'Oro

### ✅ DA FARE

| Regola | Dove | Esempio |
|---|---|---|
| `ref.watch()` | Dentro `build()` dei widget | `ref.watch(userProvider)` |
| `ref.read()` | Dentro callbacks (`onPressed`, `onTap`) | `ref.read(authProvider.notifier).login()` |
| `ref.listen()` | Per side-effects (navigazione, snackbar) | `ref.listen(authProvider, (_, next) { ... })` |
| `AsyncValue.guard()` | Per gestire errori nel controller | `state = await AsyncValue.guard(() => ...)` |
| `ref.invalidateSelf()` | Per forzare un refresh del provider | `retry() { ref.invalidateSelf(); }` |

### ❌ DA NON FARE

| Errore | Perché |
|---|---|
| `ref.watch()` in un callback | Crash! Watch va usato solo in build() |
| Chiamate API nel widget | Il widget deve essere "stupido", chiama il Controller |
| `import 'package:dio'` nel Domain Layer | Il Domain deve restare Dart puro |
| Navigare con `ref.watch()` | Usa `ref.listen()` per i side-effects |

---

## 5. 🗺️ GoRouter e Navigazione

### Struttura delle rotte

```
/                    ← SplashScreen (check token)
/login               ← LoginScreen (fuori dalla shell, NO navbar)
├── /home            ← HomePage (dentro la ShellRoute, CON navbar)
│   └── /home/users/detail  ← DetailPage (sotto-rotta della home)
├── /search          ← Tab Cerca
└── /profile         ← Tab Profilo
```

### ShellRoute — La Navbar persistente

La `StatefulShellRoute.indexedStack` è la chiave per avere una navbar che resta fissa mentre i contenuti cambiano:

```dart
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) {
    return ScaffoldWithNavbar(navigationShell: navigationShell);
  },
  branches: [
    // Ogni branch è un tab della navbar
    StatefulShellBranch(routes: [GoRoute(path: '/home', ...)]),
    StatefulShellBranch(routes: [GoRoute(path: '/search', ...)]),
    StatefulShellBranch(routes: [GoRoute(path: '/profile', ...)]),
  ],
);
```

### Redirect Guard — Protezione delle rotte

Il router ha un callback `redirect` che controlla l'autenticazione ad ogni navigazione:

```dart
redirect: (context, state) {
  final isLoggedIn = ...;
  if (!isLoggedIn && !isGoingToLogin) return '/login';  // Forza login
  if (isLoggedIn && isGoingToLogin) return '/home';     // Salta il login
  return null; // Tutto ok
},
```

### Come navigare

```dart
// Navigazione diretta (sostituisce la pagina corrente)
context.go('/home');

// Navigazione con push (aggiunge alla pila)
context.push('/home/users/detail');

// Passare dati a una rotta
context.go('/home/users/detail', extra: userObject);
```

---

## 6. 🏗️ Come Aggiungere una Nuova Feature

Esempio: vuoi aggiungere la feature **"Ordini"**.

### Step 1: Domain (definisci il contratto)

```dart
// lib/features/orders/domain/entities/order.dart
abstract class Order {
  int get id;
  String get title;
  double get total;
  DateTime get createdAt;
}
```

```dart
// lib/features/orders/domain/repositories/order_repository.dart
import '../entities/order.dart';

abstract class OrderRepository {
  Future<List<Order>> getOrders();
  Future<Order> getOrderById(int id);
}
```

### Step 2: Data (implementa con Freezed e Dio)

```dart
// lib/features/orders/data/models/order_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/order.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

@freezed
sealed class OrderModel with _$OrderModel implements Order {
  const OrderModel._();

  const factory OrderModel({
    required int id,
    required String title,
    required double total,
    required DateTime createdAt,
  }) = _OrderModel;

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);
}
```

Poi esegui:
```bash
dart run build_runner build --delete-conflicting-outputs
```

```dart
// lib/features/orders/data/repositories/order_repository_impl.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../models/order_model.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(ref.read(dioProvider));
});

class OrderRepositoryImpl implements OrderRepository {
  final Dio _dio;
  OrderRepositoryImpl(this._dio);

  @override
  Future<List<Order>> getOrders() async {
    final response = await _dio.get('/api/orders');
    final list = response.data as List<dynamic>;
    return list.map((json) => OrderModel.fromJson(json)).toList();
  }

  @override
  Future<Order> getOrderById(int id) async {
    final response = await _dio.get('/api/orders/$id');
    return OrderModel.fromJson(response.data);
  }
}
```

### Step 3: Presentation (Controller + Screen)

```dart
// lib/features/orders/presentation/providers/order_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/entities/order.dart';

final orderControllerProvider =
    AsyncNotifierProvider<OrderController, List<Order>>(() {
  return OrderController();
});

class OrderController extends AsyncNotifier<List<Order>> {
  @override
  Future<List<Order>> build() async {
    final repo = ref.read(orderRepositoryProvider);
    return repo.getOrders();
  }

  /// Ricarica la lista (pull-to-refresh, ecc.)
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(orderRepositoryProvider);
      return repo.getOrders();
    });
  }
}
```

```dart
// lib/features/orders/presentation/screens/order_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/order_controller.dart';

class OrderListScreen extends ConsumerWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch → la UI si aggiorna automaticamente!
    final ordersState = ref.watch(orderControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('I miei Ordini')),
      body: ordersState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Errore: $e')),
        data: (orders) => ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, i) => ListTile(
            title: Text(orders[i].title),
            subtitle: Text('€${orders[i].total.toStringAsFixed(2)}'),
          ),
        ),
      ),
    );
  }
}
```

### Step 4: Aggiungi la rotta in `router_provider.dart`

```dart
// Dentro la ShellRoute, aggiungi un nuovo branch:
StatefulShellBranch(
  routes: [
    GoRoute(
      path: '/orders',
      builder: (context, state) => const OrderListScreen(),
    ),
  ],
),
```

E aggiorna `scaffold_with_nav.dart` per aggiungere l'icona nella navbar.

---

## 7. 🔄 Pattern Comuni

### Gestire Loading / Error / Data nella UI

```dart
// Il pattern standard: ref.watch + .when()
final state = ref.watch(myProvider);

return state.when(
  loading: () => const CircularProgressIndicator(),
  error: (error, stack) => Text('Errore: $error'),
  data: (data) => Text('Dati: $data'),
);
```

### Dio Interceptor — Token automatico

Il file `dio_provider.dart` aggiunge automaticamente il token a **ogni** richiesta HTTP:

```dart
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) async {
    final token = authLocalDataSource.getUser()?.token;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  },
));
```

**Non devi mai passare il token manualmente nelle tue chiamate API!**

### Dependency Injection con Provider

```dart
// 1. Crea il Provider del Repository
final myRepoProvider = Provider<MyRepository>((ref) {
  final dio = ref.read(dioProvider);  // Inietta Dio
  return MyRepositoryImpl(dio);
});

// 2. Usalo nel Controller
class MyController extends AsyncNotifier<MyData> {
  @override
  Future<MyData> build() async {
    final repo = ref.read(myRepoProvider);  // Inietta il repo
    return repo.getData();
  }
}
```

### SharedPreferences — Override nel main

```dart
// Il "trucco": SharedPreferences è async, ma i Provider sono sincroni.
// Soluzione: la inizializziamo PRIMA di runApp e la iniettiamo con override.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(ProviderScope(
    overrides: [
      sharedPrefsProvider.overrideWithValue(prefs),
    ],
    child: App(),
  ));
}
```

---

## 8. 🛠️ Comandi Utili

| Comando | Cosa fa |
|---|---|
| `flutter run` | Avvia l'app in debug |
| `flutter run -d chrome` | Avvia su browser web |
| `dart run build_runner build --delete-conflicting-outputs` | Genera codice Freezed/JSON |
| `dart run build_runner watch --delete-conflicting-outputs` | Genera in automatico ad ogni salvataggio |
| `flutter analyze` | Controlla errori e warning |
| `flutter clean && flutter pub get` | Pulizia e reinstallazione dipendenze |

---

## 9. ❓ FAQ — Domande Frequenti

Domande reali che emergono quando si lavora con questo template per la prima volta.

### Q1: Devo usare SEMPRE `ref.listen` + `ref.watch` insieme?

**No!** La combo serve solo quando devi fare **sia** un side-effect (navigazione, snackbar) **sia** mostrare la UI. La regola è semplice:

```
"Devo MOSTRARE qualcosa?"          → solo ref.watch + .when()
"Devo FARE qualcosa (azione)?"     → solo ref.listen
"Devo MOSTRARE e anche FARE?"      → ref.watch + ref.listen (caso raro)
```

**Esempio pratico**: una lista ordini NON ha bisogno di `ref.listen`. Vuoi solo mostrare loading/dati/errore:

```dart
// ✅ Basta ref.watch!
final ordersState = ref.watch(orderControllerProvider);
return ordersState.when(
  loading: () => CircularProgressIndicator(),
  error: (e, _) => Text('Errore: $e'),
  data: (orders) => ListView.builder(/* ... */),
);
```

**Quando serve `ref.listen`**: navigazione dopo login, snackbar dopo un'azione, logout forzato.

```dart
// ✅ ref.listen per side-effect: mostrare snackbar dopo eliminazione
ref.listen(deleteOrderProvider, (_, next) {
  if (next.hasValue) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ordine eliminato!')),
    );
  }
});
```

---

### Q2: Nello Splash Screen, il loading come funziona esattamente?

Ecco la timeline precisa di cosa succede frame per frame:

```
TEMPO    authControllerProvider    ref.listen                    ref.watch (UI)
─────    ─────────────────────    ──────────────────────        ──────────────
 T0      AsyncLoading              next.isLoading → non fa      .when(loading:) → Spinner 🔄
                                   nulla                        
 T1a     AsyncData(User)           whenData → go('/home') 🏠   .when(data:) → Spinner*
 T1b     AsyncData(null)           whenData → go('/login') 🔑  .when(data:) → Spinner*
 T1c     AsyncError(errore)        non è data → non fa nulla   .when(error:) → "Riprova" ❌
```

**Punti chiave**:
- `ref.listen` e `ref.watch` reagiscono **entrambi** allo stesso cambio di stato, in parallelo
- Nessuno "sovrascrive" l'altro: listen fa azioni, watch ricostruisce la UI
- Durante `AsyncLoading`, il listen **non fa nulla** (il callback controlla `next.isLoading`)
- Il listen non "riparte" dopo il watch — sono due listener separati sullo stesso provider

*\*Al T1a/T1b il watch farebbe rebuild, ma la navigazione è già in corso → non vedi il cambio UI.*

---

### Q3: Perché usare `rethrow` nel catch invece di `return null`?

Questo è l'errore più comune e più subdolo. In un `AsyncNotifier`, il valore che ritorni da `build()` diventa l'**unico** modo per Riverpod di sapere cosa è successo:

```dart
// ❌ SBAGLIATO: tutti gli errori diventano "nessun utente"
catch (error) {
  return null;  // Riverpod vede → AsyncData(null) → "ah, nessun utente, ok"
}

// ✅ CORRETTO: solo il 401 ritorna null, gli altri errori propagano
on DioException catch (e) {
  if (e.response?.statusCode == 401) {
    return null;  // → AsyncData(null) → "token invalido, vai al login"
  }
  rethrow;        // → AsyncError(e) → "errore di rete, mostra Riprova"
}
```

**La regola**: `AsyncValue` ha **3 stati per un motivo**. Se comprimi error dentro data (facendo `return null` nel catch), perdi la capacità di reagire agli errori nella UI.

| Cosa fai nel catch | AsyncValue risultante | La UI può mostrare "Riprova"? |
|---|---|---|
| `return null` | `AsyncData(null)` | ❌ No, pensa che non c'è utente |
| `rethrow` | `AsyncError(exception)` | ✅ Sì! |

---

### Q4: Perché nel caso `data` dello splash mostro ancora lo spinner?

```dart
authState.when(
  loading: () => Spinner(),
  data: (_) => Spinner(),    // ← Perché non mostro qualcos'altro?
  error: (e, _) => Riprova(),
);
```

Perché tra il momento in cui `ref.watch` fa rebuild con `AsyncData` e il momento in cui `context.go()` (dal `ref.listen`) cambia pagina, c'è **un frame** di differenza. Se in quel frame mostrassi qualcosa di diverso (tipo una pagina vuota o un testo), l'utente vedrebbe un "flash" per un istante.

Lo spinner dà **continuità visiva**:
```
loading → spinner → AsyncData arriva → spinner (stesso!) → navigazione → nuova pagina
```

Invece di:
```
loading → spinner → AsyncData arriva → pagina vuota (flash!) → navigazione → nuova pagina
```

---

### Q5: Qual è la differenza tra `catch (error)` e `on DioException catch (e)`?

```dart
// ❌ Pericoloso: cattura TUTTO, anche errori che non ti aspetti
catch (error) {
  final errorDio = error as DioException;  // CRASH se non è DioException!
}

// ✅ Sicuro: cattura SOLO DioException
on DioException catch (e) {
  // 'e' è già del tipo giusto, nessun cast necessario
  // Se l'errore fosse un FormatException, NON verrebbe catturato qui
  // → Riverpod lo gestirebbe come AsyncError (giusto!)
}
```

**Regola**: usa sempre `on TipoSpecifico catch (e)` per catturare solo gli errori che sai come gestire. Tutto il resto deve propagarsi naturalmente.

---

## 🎯 Checklist per Clonare il Template

Quando cloni questo template per un nuovo progetto:

1. **Rinomina il progetto**: cerca e sostituisci `flutter_base_setup` con il nome del tuo progetto in `pubspec.yaml`, Android manifest, iOS bundle, ecc.
2. **Cambia l'URL base** in `dio_provider.dart` (riga `baseUrl`)
3. **Adatta il modello User** in `auth/data/models/user_model.dart` ai campi del tuo backend
4. **Adatta gli endpoint API** in `auth_repository_impl.dart` (`/api/auth/signin`, `/api/auth/validate`)
5. **Aggiungi le tue feature** seguendo la guida al punto 6
6. **Rigenera il codice**: `dart run build_runner build --delete-conflicting-outputs`

---

> **💡 Consiglio**: Quando sei in dubbio, guarda la feature `auth` come esempio completo di tutti i layer. È il "campione" da seguire per ogni nuova feature che crei.

