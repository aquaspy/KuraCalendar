# KuraCalendar

**A calendar that remembers people and days — not every meeting protocol on earth.**

KuraCalendar is a quiet personal calendar PWA. Mark days, keep yearly birthdays, turn on public holidays for the countries you care about. Several people can share one server with separate accounts. One SQLite file. No Redis. No CalDAV. No ICS-as-the-database.

---

## Philosophy

Calendar software tends to become infrastructure: invite RSVPs, free/busy, timezone hell, sync conflicts across three devices and a watch. That is a real product for workplaces. It is the wrong product for “when is mom’s birthday” and “don’t forget the long weekend.”

KuraCalendar is the second kind.

- **Days you mark, birthdays that repeat.** Simple events with times when you need them. Birthdays that come back every year without ceremony.
- **Holidays as packs, not plugins.** Flip on Brazil, the United States, Slovenia, and/or Czechia. Enough for a life that spans places — not a marketplace of calendar feeds.
- **Your data stays a file.** Export JSON when you want a copy. Import adds; it does not overwrite your life by accident.
- **No protocol cosplay.** If you need CalDAV and shared free/busy, use something built for that. This app is for *you*, on a VPS you trust.
- **Same Kura shell.** Auth, idle lock (per device), PWA offline month views, Compose on localhost.

Sister apps: [KuraNotes](https://github.com/aquaspy/KuraNotes), [KuraChat](https://github.com/aquaspy/KuraChat), [KuraHome](https://github.com/aquaspy/KuraHome), [KuraSpend](https://github.com/aquaspy/KuraSpend). Each keeps its own volume — a calendar should not share a database with chat history.

---

## What you get

- Multi-user accounts on one instance
- Month (and day) views with events and birthdays
- Holiday packs: **BR**, **US**, **SI**, **CZ**
- JSON export / import (import adds rows; it does not replace)
- API tokens + JSON API for AI agents (see API.md)
- Offline: reopen months you already opened; edits wait until you are back
- Sign-out wipes the offline cache

---

## Self-host (Docker Compose)

```bash
git clone https://github.com/aquaspy/KuraCalendar.git
cd KuraCalendar
cp .env.example .env
```

Edit `.env`. At minimum:

```bash
SECRET_KEY_BASE=          # paste: openssl rand -hex 64
KURA_HOST=calendar.example.com
SIGNUP_ENABLED=true       # first account, then false
FORCE_SSL=false           # true once HTTPS terminates in front
BIND=127.0.0.1:3003       # 3003 if Notes/Chat/Home already took 3000+
```

Then:

```bash
docker compose up -d --build
```

Create the first account in the browser (`http://127.0.0.1:3003`), or:

```bash
docker compose exec web bin/rails kura:create EMAIL=you@example.com PASSWORD='at-least-8'
```

Lock signup:

```bash
# in .env
SIGNUP_ENABLED=false
docker compose up -d
```

> **Important:** `docker compose restart` does **not** reload `.env`. Use `docker compose up -d`.

### Secrets

Pick **one**. You do not need both.

| Approach | When | How |
| --- | --- | --- |
| **`SECRET_KEY_BASE`** (recommended) | Compose / VPS | `openssl rand -hex 64` → `.env` |
| **`RAILS_MASTER_KEY`** | Rails credentials | Regenerate with `EDITOR=true bin/rails credentials:edit`, put `config/master.key` in `.env` |

Losing the key does not lose events — only session cookies.

### Reverse proxy (Caddy or nginx)

Nothing is bundled. Point your proxy at `BIND`, set `FORCE_SSL=true`, then `docker compose up -d`.

**Caddy:**

```
calendar.example.com {
  reverse_proxy 127.0.0.1:3003
}
```

**nginx:**

```
location / {
  proxy_pass http://127.0.0.1:3003;
  proxy_http_version 1.1;
  proxy_set_header Host $host;
  proxy_set_header X-Forwarded-Proto $scheme;
}
```

If `BIND` is another port, proxy to that port instead.

### Users on the server

No email recovery — `kura:password` is the admin reset:

```bash
docker compose exec web bin/rails kura:users
docker compose exec web bin/rails kura:create EMAIL=you@example.com PASSWORD='at-least-8'
docker compose exec web bin/rails kura:password EMAIL=you@example.com PASSWORD='new-secret'
```

### Backup

Events and birthdays live in the `kura_calendar_data` volume (`storage/production.sqlite3`).

```bash
docker compose exec web tar -C /rails/storage -cf - . > kuracalendar-backup.tar
```

### Shared browsers

Sign out **and** wait for the cache wipe.

### Runtime (queue & YJIT)

Solid Queue is **off** here. This app has no durable background jobs, so production Active Job uses the in-process `:async` adapter and Compose does not set `SOLID_QUEUE_IN_PUMA`. That keeps the extra queue processes from sitting in RAM. [KuraChat](https://github.com/aquaspy/KuraChat) still runs Solid Queue for completion jobs.

YJIT stays **on**. Rails 8.1 enables it in production via `config.yjit`; the image also sets `RUBY_YJIT_ENABLE=1`. Leave it on — the CPU win is worth the modest RSS on a personal box.

---

## Import / export

**Export** downloads JSON of events and birthdays.

**Import** accepts that same JSON. It **adds** rows; it does not replace existing ones.

---

## AI agents (API)

KuraCalendar is ready for the agentic era: mint a token under **More → API tokens**, hand it to OpenClaw, Hermes Agent, or any HTTP client, and it can read and manage events and birthdays — even while the app is locked. See [API.md](API.md) for endpoints, curl examples, and a setup snippet.

---

## Local development

```bash
bin/setup
bin/dev
```

Open http://127.0.0.1:3000

If you cloned without a `master.key`:

```bash
rm -f config/credentials.yml.enc
EDITOR=true bin/rails credentials:edit
```

Do not commit `config/master.key`.

---

## Environment

| Variable | What it does |
| --- | --- |
| `SECRET_KEY_BASE` | Session cookies (Compose). `openssl rand -hex 64` |
| `SIGNUP_ENABLED` | Public signup. Turn off after the first account |
| `FORCE_SSL` | `true` when Caddy/nginx terminates HTTPS |
| `KURA_HOST` | Public hostname |
| `BIND` | Default `127.0.0.1:3003` |

---

## Sister apps

| App | Role |
| --- | --- |
| [KuraNotes](https://github.com/aquaspy/KuraNotes) | Private notes |
| [KuraChat](https://github.com/aquaspy/KuraChat) | Private chat with Grok |
| [KuraHome](https://github.com/aquaspy/KuraHome) | Quiet start-page / homepage |
| [KuraSpend](https://github.com/aquaspy/KuraSpend) | Subscriptions & daily spend |
