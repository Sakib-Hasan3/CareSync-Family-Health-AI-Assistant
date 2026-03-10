# CareSync AI Proxy

This is a minimal Node/Express proxy intended for local development or a small private deployment.
It keeps your AI API key on the server (never embed keys in mobile builds).

## Quick start

1. Install dependencies:

```bash
cd tools/proxy
npm install
```

2. Set your API key in the environment. Supported env vars:
- `DEEPSEEK_API_KEY` (preferred if using Deepseek)
- `OPENAI_API_KEY` (fallback)
- `DEEPSEEK_API_URL` (optional) — override the upstream API URL if necessary.
- `AI_MODEL` (optional) — model name to request (default: `gpt-4o-mini`).

Example (Linux/macOS):

```bash
export DEEPSEEK_API_KEY="sk-your-key-here"
export PORT=8080
node server.js
```

On Windows (PowerShell):

```powershell
$env:DEEPSEEK_API_KEY = "sk-your-key-here"
$env:PORT = "8080"
node server.js
```

3. From the mobile app, run with:

```bash
flutter run --dart-define=AI_PROXY_URL=http://<proxy-host>:8080
```

The app will POST JSON to `/ask` and `/askWithImage` endpoints.

Security note: This proxy stores the API key in the server environment. For production use, add authentication, rate-limiting, and logging protections. Do not expose it directly to the public without proper controls.
