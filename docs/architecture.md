# Campus Notifier services

```mermaid
flowchart LR
    user["Campus user"]
    events["Events service<br/>(Django app)<br/>Browse and manage events;<br/>register for events"]
    notifications["Notification service<br/>(Django app / data models)<br/>Preferences, subscriptions,<br/>notification records"]

    user -->|"browse events · register"| events
    notifications -->|"notification records reference events and categories"| events
```

Both apps currently run inside the same Django application and use the same configured database. The notification app has data models, but no user-facing endpoints or delivery worker yet, so events do not trigger outgoing notifications.
