# Presentation

Qui risiede l'**interfaccia utente (UI)** e la **logica di stato**.
Questo layer consuma i dati del *Domain* e reagisce agli input dell'utente.

- **providers**
  Contiene i Controller (Riverpod Notifiers). Gestiscono lo stato della UI e comunicano con il
  *Domain*.

- **screens**
  Le schermate complete dell'applicazione (es. `LoginScreen`, `HomePage`).

- **widgets**
  Componenti grafici riutilizzabili e piccoli (es. `CustomButton`, `UserCard`).