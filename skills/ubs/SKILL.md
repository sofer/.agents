---
name: ubs
description: Ultimate Bug Scanner - static analysis catching 1000+ bug patterns across all major languages
source: https://github.com/Dicklesworthstone/ultimate_bug_scanner
---

# UBS (Ultimate Bug Scanner)

Static analysis tool that catches 1000+ bug patterns across all popular programming languages, with auto-wiring into AI coding agent quality guardrails.

## What It Does

Scans code for common bugs that AI coding agents frequently introduce:

- **Null/undefined access** without guards
- **Missing await** on async calls
- **Security holes** (XSS, eval injection, SQL injection)
- **Resource leaks** (unclosed files, missing defer/finally)
- **Type coercion bugs** (parseInt without radix, NaN comparisons)
- **Buffer overflows** (strcpy, gets in C/C++)
- **Panic risks** (.unwrap() in Rust, unhandled errors in Go)

## Supported Languages

JavaScript/TypeScript, Python, C/C++, Rust, Go, Java, Ruby, Swift

## Installation

```bash
curl -fsSL "https://raw.githubusercontent.com/Dicklesworthstone/ultimate_bug_scanner/master/install.sh?$(date +%s)" | bash -s -- --easy-mode
```

Or via Homebrew:

```bash
brew install dicklesworthstone/tap/ubs
```

## Usage

### Basic Scan

```bash
# Scan current directory
ubs .

# Scan specific path
ubs ./src
```

### Agent-Friendly Output

```bash
# JSON output for parsing
ubs . --format=json

# Token-optimized output (TOON)
ubs . --format=toon

# Scan only staged changes
ubs --staged --format=json
```

### CI Integration

```bash
# Strict mode - fail on warnings
ubs . --profile=strict --fail-on-warning --format=json

# Compare against baseline
ubs . --comparison=baseline.json
```

## When to Use

1. **Before committing** — Run `ubs --staged` to catch bugs in changed files
2. **In CI pipelines** — Add to PR checks with `--fail-on-warning`
3. **During code review** — Generate reports with `--html-report=bugs.html`
4. **Agent guardrails** — Wire into coding agent hooks for continuous scanning

## Category Packs

Focus scans on specific concerns:

```bash
# Resource lifecycle issues only
ubs . --category=resource-lifecycle

# Security-focused scan
ubs . --category=security
```

## References

- [GitHub Repository](https://github.com/Dicklesworthstone/ultimate_bug_scanner)
- [Language Modules](https://github.com/Dicklesworthstone/ultimate_bug_scanner/tree/master/modules)
