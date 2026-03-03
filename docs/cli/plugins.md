---
summary: "CLI reference for `forge-orchestrator plugins` (list, install, uninstall, enable/disable, doctor)"
read_when:
  - You want to install or manage in-process Gateway plugins
  - You want to debug plugin load failures
title: "plugins"
---

# `forge-orchestrator plugins`

Manage Gateway plugins/extensions (loaded in-process).

Related:

- Plugin system: [Plugins](/tools/plugin)
- Plugin manifest + schema: [Plugin manifest](/plugins/manifest)
- Security hardening: [Security](/gateway/security)

## Commands

```bash
forge-orchestrator plugins list
forge-orchestrator plugins info <id>
forge-orchestrator plugins enable <id>
forge-orchestrator plugins disable <id>
forge-orchestrator plugins uninstall <id>
forge-orchestrator plugins doctor
forge-orchestrator plugins update <id>
forge-orchestrator plugins update --all
```

Bundled plugins ship with ForgeOrchestrator but start disabled. Use `plugins enable` to
activate them.

All plugins must ship a `forge-orchestrator.plugin.json` file with an inline JSON Schema
(`configSchema`, even if empty). Missing/invalid manifests or schemas prevent
the plugin from loading and fail config validation.

### Install

```bash
openclaw plugins install <path-or-spec>
openclaw plugins install <npm-spec> --pin
```

Security note: treat plugin installs like running code. Prefer pinned versions.

Npm specs are **registry-only** (package name + optional version/tag). Git/URL/file
specs are rejected. Dependency installs run with `--ignore-scripts` for safety.

If a bare install spec matches a bundled plugin id (for example `diffs`), OpenClaw
installs the bundled plugin directly. To install an npm package with the same
name, use an explicit scoped spec (for example `@scope/diffs`).

Supported archives: `.zip`, `.tgz`, `.tar.gz`, `.tar`.

Use `--link` to avoid copying a local directory (adds to `plugins.load.paths`):

```bash
forge-orchestrator plugins install -l ./my-plugin
```

Use `--pin` on npm installs to save the resolved exact spec (`name@version`) in
`plugins.installs` while keeping the default behavior unpinned.

### Uninstall

```bash
forge-orchestrator plugins uninstall <id>
forge-orchestrator plugins uninstall <id> --dry-run
forge-orchestrator plugins uninstall <id> --keep-files
```

`uninstall` removes plugin records from `plugins.entries`, `plugins.installs`,
the plugin allowlist, and linked `plugins.load.paths` entries when applicable.
For active memory plugins, the memory slot resets to `memory-core`.

By default, uninstall also removes the plugin install directory under the active
state dir extensions root (`$FORGE_ORCH_STATE_DIR/extensions/<id>`). Use
`--keep-files` to keep files on disk.

`--keep-config` is supported as a deprecated alias for `--keep-files`.

### Update

```bash
forge-orchestrator plugins update <id>
forge-orchestrator plugins update --all
forge-orchestrator plugins update <id> --dry-run
```

Updates only apply to plugins installed from npm (tracked in `plugins.installs`).

When a stored integrity hash exists and the fetched artifact hash changes,
OpenClaw prints a warning and asks for confirmation before proceeding. Use
global `--yes` to bypass prompts in CI/non-interactive runs.
