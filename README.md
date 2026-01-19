# Glasscast ☁️✨

A minimal weather app built with Flutter using an AI-first development workflow.

## 📱 Features

* Supabase Email Authentication (Login / Signup)
* Current weather display (temperature, condition, high/low)
* 5-day forecast cards
* City search with favorite saving
* Favorites synced per user via Supabase
* Temperature unit toggle (°C / °F)
* Pull-to-refresh
* Glassmorphism (Liquid Glass inspired UI)
* Smooth animations & polished UI

---

## 🧱 Tech Stack

* Flutter 3
* Supabase (Auth + Database)
* OpenWeatherMap API
* Dio for networking
* Cubit (flutter_bloc) for state management
* HydratedCubit for settings persistence

---

## ⚙️ Setup Instructions

### 1) Clone Repository

```
git clone https://github.com/yash1711v/BrewWheather.git
cd glasscast
flutter pub get
```

---

### 2) Supabase Setup

Create a free Supabase project at:
[https://supabase.com](https://supabase.com)

In Supabase SQL Editor, run:

```sql
create table favorite_cities (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users default auth.uid(),
  city_name text,
  lat double precision,
  lon double precision,
  created_at timestamp default now()
);

alter table favorite_cities enable row level security;

create policy "Users manage own favorites"
on favorite_cities
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);
```

Enable Email Authentication:
Authentication → Providers → Email → Enable

---

### 3) Get Supabase Keys

Go to:
Settings → API

Copy:

* Project URL → `Env.supabaseUrl`
* anon public key → `Env.supabaseAnonKey`

Paste into:

```
lib/core/env/env.dart
```

---

### 4) Get OpenWeatherMap API Key

Create free account:
[https://openweathermap.org/api](https://openweathermap.org/api)

Copy API key and paste into:

```
static const weatherApiKey = "YOUR_KEY";
```

---

### 5) Run App

```
flutter run
```

---

## 🎨 Design

UI designed using AI-assisted design tooling
Glassmorphism inspired by iOS 26 Liquid Glass design language.

stitch link: https://stitch.withgoogle.com/projects/14012105606548756382

---

## 🤖 AI-First Development Workflow

This project was developed using AI-assisted coding with Cursor / Claude Code.
See `CLAUDE.md` for AI context instructions.
A screen recording demonstrates prompting, iteration, debugging, and AI collaboration.

---

## 📸 Screenshots
url: https://drive.google.com/drive/folders/1XYn8_znjHcGD6YEKtrb0diOZbN6PH_FB?usp=sharing

---

## 📦 Deliverables

* Full Flutter source code
* Supabase backend integration
* AI workflow recording
* AI design file (Figma / Google Stitch)

---

## 👤 Author

Yash Verma
