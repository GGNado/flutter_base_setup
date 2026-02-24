# Flutter Base Setup — Feature-First Clean Architecture (Riverpod)

Un template Flutter scalabile e professionale, pronto da clonare per qualsiasi nuovo progetto. Basato su **Feature-First Clean Architecture** con Riverpod, GoRouter, Dio e Freezed.

## ✨ Cosa include

- 🔐 **Autenticazione completa** — Login, validazione token, splash screen con retry
- 🏗️ **Clean Architecture** — Domain → Data → Presentation (3 layer per feature)
- 📱 **Navigazione** — GoRouter con ShellRoute (navbar persistente) e redirect guard
- 🌐 **Networking** — Dio configurato con interceptor per token automatico
- 💾 **Storage locale** — SharedPreferences per persistere l'utente
- 🧊 **Code generation** — Freezed + json_serializable per modelli immutabili

## 📖 Guida per Principianti

👉 **Leggi la [GUIDA_TEMPLATE.md](GUIDA_TEMPLATE.md)** per una spiegazione dettagliata di tutto il progetto, scritta per chi è alle prime armi con Riverpod.

## 🚀 Quick Start

```bash
# 1. Clona il progetto
git clone <url-del-repo> nome_tuo_progetto

# 2. Installa le dipendenze
flutter pub get

# 3. Genera il codice (Freezed + JSON)
dart run build_runner build --delete-conflicting-outputs

# 4. Configura il backend
# Modifica baseUrl in lib/core/network/dio_provider.dart

# 5. Lancia l'app
flutter run
```

## 📁 Struttura

```
lib/
├── core/                     # Componenti condivisi
│   ├── network/              # Dio + Interceptors
│   ├── router/               # GoRouter + Redirect Guard
│   ├── storage/              # SharedPreferences
│   └── widgets/              # Widget riutilizzabili
└── features/
    ├── auth/                 # Login, Splash, Token validation
    ├── home/                 # Dashboard
    └── user/                 # Esempio CRUD (lista utenti)
```

## 🔐 Flusso di Autenticazione

```
App aperta → Splash Screen → Token salvato?
                                ├── NO → Login
                                └── SI → Verifica col backend
                                           ├── OK → Home
                                           ├── 401 → Login
                                           └── Errore rete → Riprova
```

## 🛠️ Tech Stack

| Libreria | Versione | Ruolo |
|---|---|---|
| `flutter_riverpod` | ^3.0.3 | State Management |
| `dio` | ^5.9.0 | HTTP Client |
| `go_router` | ^17.0.1 | Navigazione dichiarativa |
| `freezed` | ^3.2.3 | Code generation (modelli) |
| `json_serializable` | ^6.11.2 | Serializzazione JSON |
| `shared_preferences` | ^2.5.4 | Storage locale |

## 📋 Checklist per Clonare

1. Rinomina `flutter_base_setup` ovunque nel progetto
2. Cambia `baseUrl` in `dio_provider.dart`
3. Adatta `UserModel` ai campi del tuo backend
4. Modifica gli endpoint API in `auth_repository_impl.dart`
5. Rigenera il codice: `dart run build_runner build --delete-conflicting-outputs`
6. Aggiungi le tue feature seguendo la [guida](GUIDA_TEMPLATE.md#6--come-aggiungere-una-nuova-feature)
