---
owner: orchestrator
state: running
reason: ""
updated: 1970-01-01 00:00:00
---

# CONTROL — run-state semaphore

> Written **only** by the orchestrator. Every agent reads `state:` at the top of each cycle.

| state | meaning | each agent does |
|---|---|---|
| `running` | normal | continue the loop |
| `paused` | stop | finish current item, record `state: paused` in own STATUS, wait |
| `draining` | wind down | finish in-flight, start nothing new, then idle |

## How to stop / resume the swarm
- **Stop / kill-switch**: set `state: paused` (+ `reason`), commit. All agents halt at next cycle check.
- **Resume**: set `state: running`, commit.
- Use `paused` for runaways too — cost spikes, error loops, anything unexpected.

## Change log (append-only)
- 1970-01-01 | CREATE | template initialized, state=running | orchestrator
