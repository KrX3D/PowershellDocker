---
name: babysit
description: Repo-specific guidance for driving PowershellDocker PRs to a mergeable state.
---

# PowershellDocker PR guidance

This repo builds a PowerShell Docker image (`DOCKERFILE`) and publishes it to
`ghcr.io/krx3d/powershelldocker` via `.github/workflows/build-and-push.yml`
on pushes to `main` and `v*.*.*` tags. `.github/workflows/pr-validate.yml`
runs on every pull request and is the thing to make green:

- `shellcheck entrypoint.sh` — must be clean (or only info-level `SC2086`
  notices already accepted upstream). Quote every variable expansion in
  new shell code.
- A PowerShell parser check over all `*.ps1` files — catches syntax errors
  without needing a live Windows/PSWSMan environment.
- `docker build -f DOCKERFILE .` (no push) — confirms the image still
  builds. Note: `PSWSMan`/`Install-WSMan` steps require real outbound
  internet access to the PowerShell Gallery; a build failing only on that
  step inside a network-restricted sandbox is an environment limitation,
  not a regression — verify by trying the same step on `main` before
  concluding a PR broke it.

## Conventions and known pitfalls

- Never hardcode a personal or internal network address (DNS server, IP,
  hostname) into `entrypoint.sh` or `DockerDefault.ps1` — this image is
  published publicly and runs on other people's networks. Use an
  overridable environment variable with a public/sane default instead
  (see `FALLBACK_DNS` in `entrypoint.sh`).
- `entrypoint.sh` intentionally tolerates individual `apt-get install`
  failures inside the `EXTRA_SOFTWARE` loop (logs and continues) — don't
  add `set -e` or otherwise make that loop fail-fast without discussing
  it, since it would change documented runtime behavior.
- Keep `docker-compose.yml` and the README in sync with any new
  environment variables `entrypoint.sh` reads.
- There is no automated test suite beyond the checks above — treat the
  ShellCheck, PowerShell-syntax, and Docker-build checks as the bar for
  "safe to merge."
