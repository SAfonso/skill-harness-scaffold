# skill-harness-scaffold

> A Claude Code Skill that bootstraps a complete multi-agent harness for any new project in one step.

![Claude Code Skill](https://img.shields.io/badge/Claude%20Code-Skill-blueviolet)

---

## About this project

This project is part of a personal learning lab. The goal was not to build a production tool, but to understand three things by actually doing them:

- **The anatomy of a Claude Code Skill** — what goes in `SKILL.md`, how the trigger description shapes when a Skill fires, how templates and workflows fit together.
- **The multi-agent harness pattern** — how to split responsibilities across leader, implementer, and reviewer agents; how to make them communicate through files instead of chat; how to encode rules that survive context resets.
- **The draft → test → iterate cycle** — designing agent instructions, finding the gaps when you try to use them, revising, and repeating until the system is coherent end to end.

Everything here is a learning artifact. If you want to understand the same things, this repo is a reasonable starting point — clone it, break it, rebuild it your way.

---

## What is this Skill

A **multi-agent harness** is a set of conventions, files, and instructions that turns Claude Code from a coding assistant into a structured engineering team: a **leader** that plans and delegates, an **implementer** that writes code, and a **reviewer** that validates before anything is marked done. Communication between agents happens through files, not chat. State lives on disk, not in memory.

The problem this Skill solves: starting a new project in Claude Code with no structure forces you to define roles, conventions, validation criteria, and error logs from scratch every time. This Skill generates all of that in one step, consistently, from a set of battle-tested templates.

What it generates: 15 files across 5 directories — agent definitions, role rules, validation criteria, a feature backlog, documentation stubs, session state files, and a health-check script — all wired together and ready to use.

---

## Generated structure

```
./
├── CLAUDE.md                        # Leader role, hard rules, startup protocol
├── AGENTS.md                        # Agent map: roles, workflow, state files
├── CHECKPOINTS.md                   # Validation criteria the reviewer checks before closing any task
├── feature_list.json                # Feature backlog with status, priority, and dependencies
├── init.sh                          # Environment health check — run at session start
│
├── .claude/
│   └── agents/
│       ├── leader.md                # Detailed leader instructions
│       ├── implementer.md           # Detailed implementer instructions
│       └── reviewer.md              # Detailed reviewer instructions
│
├── docs/
│   ├── architecture.md              # System vision, components, design decisions  ⚠ fill in
│   ├── conventions.md               # Naming, file structure, code style, commits  ⚠ fill in
│   ├── best-practices.md            # Mandatory practices applied to every task    ⚠ fill in
│   └── verification.md              # How to run tests and document results
│
├── progress/
│   ├── current.md                   # Live session state — updated at start and end
│   ├── history.md                   # Append-only log of all past sessions
│   └── errors.md                    # Error log with causes and solutions
│
└── agents/
    └── output/                      # Implementer and reviewer outputs, one file per task
```

Files marked ⚠ contain placeholder sections that must be filled in before `init.sh` passes.

---

## Installation

Copy the `skill-harness-scaffold/` directory into your Claude Code skills folder:

```bash
cp -r skill-harness-scaffold/ ~/.claude/skills/
```

Claude Code will pick it up automatically on next launch. The Skill is defined in `skill-harness-scaffold/SKILL.md`.

---

## Usage

### Phrases that trigger the Skill

- "create a new project"
- "initialize a harness"
- "setup project with Claude Code"
- "new repo"
- "start a project"
- "create project structure"
- Opening a directory in Claude Code with no `CLAUDE.md` or `feature_list.json`

When in doubt, the Skill triggers early rather than late.

### What the Skill asks

If you haven't provided a project name, it will ask:

> "What is the project name? I'll use it as the identifier across all generated files."

### What it produces

1. Creates the directory structure.
2. Generates all 15 files from `references/templates/`, substituting `{{PROJECT_NAME}}` with the real name.
3. Makes `init.sh` executable.
4. Tells you which three files need manual editing before you can start working.
5. Suggests running `bash init.sh` to verify the environment.

---

## Included examples

Two fully populated examples are included in `examples/`. Both can be opened directly in Claude Code and worked on immediately — no editing required.

### `examples/project_simple/` — todo-cli

A Python CLI that manages a task list. Three features: add task, list tasks, mark as done. Simple linear dependencies, local JSON storage. Good starting point for understanding how the harness works.

### `examples/project_data/` — public-data-pipeline

A local Python data engineering pipeline that downloads public data from datos.gob.es, cleans it, stores it in SQLite, and exports it to CSV and JSON. Four features in strict pipeline order. Demonstrates harness conventions for data projects: record counts, idempotency, schema validation, immutable raw layer.

---

## Three pillars of the harness

**The repo is the system.** All agent state, decisions, errors, and outputs live in files inside the repo. Nothing in memory, nothing in chat history. A new Claude Code session can pick up exactly where the last one left off by reading four files.

**Multi-agent orchestration.** Work is split across three agents with hard boundaries: the leader never writes code, the implementer never validates, the reviewer is the only one who can close a task. This separation eliminates a class of subtle errors where the same agent both writes and approves its own work.

**State on disk, not in context.** `progress/current.md` tracks the active task. `progress/errors.md` prevents debugging the same error twice. `feature_list.json` enforces one task at a time, dependency order, and priority. `init.sh` verifies everything is consistent before any work begins.

---

## Contributing

PRs and issues welcome — especially new examples, additional agent types, or language-specific convention templates.

---

## Roadmap

### v2 — Tools and Hooks

- **`references/templates/.claude/settings.json.tmpl`** — pre-configured tool permissions for the harness. Read, write, grep, ls, and basic bash run without confirmation. Destructive operations (git push, rm, anything irreversible) always require explicit approval.
- **`references/templates/.claude/hooks/post-commit.sh.tmpl`** — a post-commit hook that runs after each user-confirmed commit. Clears `progress/current.md` and appends the session summary to `progress/history.md`, keeping the session log in sync with git history without manual steps.

### v3 — Domain-specific scaffolding

Currently the Skill generates the same base structure for every project. In v3, the user will choose a domain (data, web, cli, library, etc.) at generation time and the Skill will adapt the content of the generated files accordingly — domain-specific conventions, validation criteria, architecture stubs, and verification guides instead of generic placeholders.
