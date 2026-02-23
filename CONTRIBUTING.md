# Contributing to Kafka Engineering Lab

**First — thank you.**

This repository is not a tutorial collection. It is a production-focused Kafka engineering lab designed for serious experimentation and real-world simulation.

We welcome contributions that improve clarity, reproducibility, operational depth, and realism.

---

## Table of Contents

- [Project Philosophy](#project-philosophy)
- [Repository Structure Rules](#repository-structure-rules)
- [Branching Strategy](#branching-strategy)
- [Merge Strategy](#merge-strategy)
- [Versioning & Releases](#versioning--releases)
- [What We Do Not Allow](#what-we-do-not-allow)
- [Contribution Standards](#contribution-standards)
- [Git Hygiene](#git-hygiene)
- [Types of Contributions](#types-of-contributions)
- [Pull Request Process](#pull-request-process)
- [Engineering Expectations](#engineering-expectations)
- [Governance](#governance)
- [Long-Term Goal](#long-term-goal)

---

## Project Philosophy

This repository is:

- **Structured intentionally** - Folder layout is fixed
- **Reproducible** - Docker-first
- **Production-oriented** - Real-world focus
- **Vendor-neutral** - No platform lock-in
- **Community-extended** - Controlled expansion

> 💡 **Core Principle:** We optimize for stability, reproducibility, and engineering depth over speed.

---

## Repository Structure Rules

> ⚠️ **Important:** The folder structure is intentionally fixed.

You may **not**:

- Rename folders
- Reorganize modules
- Move checkpoints
- Restructure curriculum sections
- Add new top-level directories

**Structural changes require maintainer approval via GitHub Discussion.**

---

## Branching Strategy

We use a **trunk-based workflow with protected main branch**. This ensures the lab remains stable and reproducible for all users.

### Branch Types

| Type | Pattern | Purpose | Example |
|------|---------|---------|---------|
| **Main** | `main` | Stable, production-ready | Always works |
| **Feature** | `feature/<module>-<description>` | Module improvements | `feature/03-consumer-lag-monitoring` |
| **Project** | `project/<name>` | Module 12 additions | `project/exactly-once-payment-sim` |
| **Infrastructure** | `infra/<change>` | Core upgrades | `infra/kafka-3.8-upgrade` |

---

### Main Branch (Protected)

> 🔒 **Protected Branch:** `main` represents a stable, working version of the lab.

**Rules:**
- ✅ Always reproducible
- ✅ Always passes CI
- ❌ No direct commits
- ✅ PR required
- ✅ At least one maintainer review required
- ✅ Squash & merge only

If you clone this repository, `main` should work without surprises.

---

### Feature Branches (Required)

All work must happen in short-lived feature branches.

**Naming format:**
```
feature/<module>-<short-description>
```

**Examples:**
```
feature/03-consumer-lag-monitoring
feature/10-broker-failure-simulation
feature/04-batch-size-performance-lab
feature/docs-checkpoint-clarity
```

**Rules:**
- Branch from latest `main`
- Keep scope focused
- One conceptual change per PR
- Delete branch after merge

---

### Large Project Branches (Module 12)

For substantial additions inside `12-real-world-projects`:

**Pattern:**
```
project/<project-name>
```

**Example:**
```
project/high-throughput-benchmark
project/exactly-once-payment-sim
```

These may remain open longer but must not destabilize `main`.

---

### Infrastructure Changes

For major infrastructure changes (e.g., Kafka version upgrades):

**Pattern:**
```
infra/<change-name>
```

**Example:**
```
infra/kafka-3.8-upgrade
```

**Requirements:**
- Full environment verification
- Validation across modules
- Maintainer approval before merge

> ⚠️ **Never modify core infrastructure directly on `main`.**

---

## Merge Strategy

We use **Squash & Merge**.

**Why:**
- Clean commit history
- Easier rollback
- Clear change descriptions
- Avoids noisy commit trails

### Commit Message Format

```
[module] short summary

- What changed
- Why
- Production relevance
```

**Example:**
```
[04-performance] add batch size tuning experiment

Introduces throughput comparison using batch.size and compression.

Production relevance:
Demonstrates latency vs throughput tradeoffs under load.
```

---

## Versioning & Releases

We use Git tags for stable milestones:

```
v1.0.0
v1.1.0
v2.0.0
```

**Versions are created when:**
- Kafka version upgraded
- Major module added
- Breaking infrastructure change introduced
- Significant production simulations added

Tags allow learners to lock into stable versions.

---

## What We Do Not Allow

> 🚫 **Critical Rules:**

- Direct commits to `main`
- Long-lived feature branches
- Force pushes
- Structural refactors without discussion
- Vendor lock-in without consensus
- Committing Kafka runtime artifacts
- Massive binary files

---

## Contribution Standards

> ✅ **Before submitting a PR, ensure:**

- `docker compose up` works cleanly
- No Kafka log directories committed
- `.gitignore` respected
- No sensitive data included
- Setup instructions are clear
- Scripts are executable and portable

**If modifying infrastructure:**
- Document the reasoning
- Explain production relevance
- Clarify trade-offs

---

## Git Hygiene

<details>
<summary><b>⚠️ Do NOT commit these files (click to expand)</b></summary>

```
*/data/
*.log
*.index
*.timeindex
*.snapshot
*.checkpoint
leader-epoch-checkpoint
```

Kafka runtime artifacts must never enter version control.

</details>

---

## Types of Contributions

<table>
<tr>
<td width="50%" valign="top">

### 📝 Documentation Improvements

- Clarify explanations
- Add architecture diagrams (Mermaid preferred)
- Expand troubleshooting
- Improve production context

</td>
<td width="50%" valign="top">

### 🔧 Lab Reliability

- Fix Docker issues
- Improve startup reliability
- Add verification scripts
- Remove machine-specific assumptions

</td>
</tr>
<tr>
<td width="50%" valign="top">

### 📊 Observability Enhancements

- JMX improvements
- Prometheus configs
- Grafana dashboards
- Consumer lag scripts

</td>
<td width="50%" valign="top">

### ✅ Checkpoint Improvements

Each module may contain:
```
checkpoint/
  ├── quiz.json
  ├── exit-criteria.json
  └── environment-verification.sh
```

You may:
- Improve quizzes
- Refine exit criteria
- Add automated validation

Checkpoints should validate understanding, not trivia.

</td>
</tr>
</table>

---

### Real-World Projects (Module 12)

**Before adding a project:**

1. Open a GitHub Discussion
2. Provide:
   - Problem statement
   - Production relevance
   - Architecture overview
   - Required infrastructure
   - Observability plan
   - Failure modes
3. Maintainer review required

Approved projects are added under `12-real-world-projects/` or spun out into standalone repositories.

---

## Pull Request Process

```
┌─────────────────┐
│ Fork Repository │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Create Feature  │
│     Branch      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Make Focused    │
│    Changes      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Validate      │
│  Environment    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Submit PR     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Address Review  │
│    Feedback     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Squash Merge    │
└─────────────────┘
```

**PRs are reviewed for:**
- Technical accuracy
- Production realism
- Reproducibility
- Structural compliance

---

## Engineering Expectations

This lab focuses on:

- Partition leadership behavior
- ISR mechanics
- Offset management
- Replication guarantees
- Consumer group rebalancing
- Performance trade-offs
- Failure recovery
- Observability under stress

> 💡 **If your contribution increases production insight, it is valuable.**

---

## Governance

**Core maintainers:**
- Approve structural changes
- Review project proposals
- Protect stability of `main`
- Ensure quality standards

**Major decisions are discussed publicly.**

---

## Long-Term Goal

To become:

- A canonical open-source Kafka engineering lab
- A portfolio-grade production training environment
- A collaborative distributed systems playground

> 🎯 **If you contribute here, you're helping build something serious.**

---

## Thank You

Contributing here means you care about:

- Distributed systems
- Production correctness
- Engineering rigor
- Reproducibility

**We appreciate that.**

Let's build something that lasts.

---

## Community

**Join the Datech Community:**

- 💬 **Discord:** [Join our community](https://discord.gg/yourlink)
- 🐦 **Twitter:** [@DatechCommunity](https://twitter.com/yourhandle)
- 💼 **LinkedIn:** [Datech Community](https://linkedin.com/company/yourcompany)
- 📅 **Luma:** [Datech Events](https://lu.ma/yourevent)
- 🌐 **Website:** [datech.community](https://yourwebsite.com)
- 📧 **Email:** community@datech.io

**Questions about contributing?** Ask in Discord #apache-kafka-learning-track or open a [GitHub Discussion](https://github.com/DatechCommunity/kafka-engineering-lab/discussions).