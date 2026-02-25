# Data

Qui risiede la **logica implementativa** e la gestione delle **sorgenti dati** (API, DB locale).
Questo layer dipende dal *Domain*.

- **datasources**
  Gestisce le connessioni grezze ai dati (es. client HTTP, query al DB).

- **models**
  DTO (Data Transfer Objects). Estendono le *Entity* aggiungendo la serializzazione (es.
  `fromJson`).

- **repositories**
  Implementazioni concrete dei repository definiti nel *Domain*. Usano le *datasources* per
  recuperare i dati.