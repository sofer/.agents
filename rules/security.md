# Security Boundaries

- Never proactively read: ~/.ssh/*, ~/.aws/*, .env*, *.pem, *.key
- Use deployment scripts that encode connection details — don't spelunk
- When credentials are needed, ask the user rather than searching for them
- Never commit: API keys, tokens, private keys, passwords
