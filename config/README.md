# Agent configuration

Shared configuration files for agent skills. Any skill that needs to write in the user's voice or reference business knowledge reads from this directory.

## Directory structure

```
config/
├── README.md                      # This file
├── voice-profile.yaml             # Voice, tone, and writing rules
└── business-context/
    ├── company.yaml               # Company info (required)
    ├── offerings.yaml             # Products and services (required)
    ├── contacts.yaml              # Key contacts (optional)
    └── terminology.yaml           # Domain terms (optional)
```

## Config-loading convention

Skills that need configuration should include instructions like the following in their SKILL.md:

### Voice profile

When writing on behalf of the user (emails, messages, posts):

1. Read `~/.agents/config/voice-profile.yaml`
2. Apply the `tone`, `language`, and `rules` fields to all written output
3. Respect the `avoid` list
4. If the file is missing, stop and tell the user: "Voice profile not found at ~/.agents/config/voice-profile.yaml"

### Business context

When the skill needs domain knowledge:

1. To load a specific category: read `~/.agents/config/business-context/{category}.yaml`
2. To load all context: read all `.yaml` files in `~/.agents/config/business-context/`
3. Ignore non-YAML files in the directory
4. If a required file is missing, stop and report which file is expected and where

### Error handling

- Missing config file: stop and report the expected path
- Malformed YAML: stop and report the parsing error
- Missing optional field: proceed with what is available

## Rules

- No API keys, passwords, tokens, or connection strings in any config file
- Secrets must be referenced via environment variables or a separate credentials mechanism
- Config files are edited manually by the user
- All files use YAML format
- Additional business context categories can be added by creating new `.yaml` files in `business-context/`
