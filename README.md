# devops-2025S-demo
class demo for devops class
pretending to add more details to the readme
completed.

## Run with Docker Compose

```bash
docker compose up --build        # app on http://localhost:8000
docker compose exec web python manage.py createsuperuser   # optional, for /admin
docker compose down              # stop (add -v to also delete the database volume)
```

Services: `db` (PostgreSQL 16, data in the `postgres_data` volume) and `web` (Django).
`web` waits for the `db` healthcheck, runs migrations, then starts the dev server.
Override DB credentials by copying `.env.example` to `.env`.
