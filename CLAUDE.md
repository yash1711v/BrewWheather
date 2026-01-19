Project: Glasscast — Flutter Weather App

Primary Goal:
Build a minimal weather app using Flutter with Supabase backend and OpenWeatherMap API, following an AI-first development workflow.

Tech Stack:

* Flutter 3
* Supabase Auth + Database
* OpenWeatherMap API
* Dio networking
* Cubit (flutter_bloc)
* HydratedCubit for persisted settings

Architecture Guidelines:

* Clean separation of concerns
* Repositories handle data access
* Cubits handle UI state
* Widgets remain presentation-only
* No direct API calls inside UI

UI Guidelines:

* Use GlassCard widget for all surfaces
* Apply blur + translucency for glassmorphism
* Dark gradient background
* Smooth fade and slide animations
* Minimal typography and spacing

Security Rules:

* No hardcoded secrets in widgets
* API keys stored in env.dart
* Supabase Row Level Security enabled

Coding Conventions:

* DioClient for HTTP
* Try/catch error handling
* Loading and error states in Cubits
* Readable, modular code

AI Workflow:

* Generate code with AI
* Iterate and debug with AI assistance
* Narrate decisions when AI makes mistakes
* Maintain clean commit history

End Goal:
A polished, production-style Flutter app demonstrating AI-assisted development.
