# Supabase setup

1. In the Supabase SQL Editor, run [`supabase/setup.sql`](supabase/setup.sql).
2. In **Authentication → Providers → Google**, enable Google and enter the OAuth client ID and secret from Google Cloud. Add Supabase's displayed callback URL to the Google OAuth client's authorized redirect URIs.
3. In **Authentication → URL Configuration**, set the site URL to `https://jerecoder.github.io/Rally-Ruta-Etica/` and add that URL to the redirect URL allow list.
4. Put the Supabase **Project URL** and **publishable key** (or legacy anon key) in `supabase-config.js`, replacing the `YOUR_...` values. Never put a service-role key in this file.

The leaderboard displays participant nicknames, car numbers, colors, and scores publicly. Progress JSON stays private to the signed-in participant through row-level security. Participants can only write rows for their own account. Scores are calculated in the browser, so this setup prevents cross-account writes but does not prevent a technically savvy user from altering their own score.
