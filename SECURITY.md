# Security Policy

## PaperMade trust boundary

PaperMade is a paper-trading simulator. It should never require a seed phrase, private key, wallet-signing permission, or custody of real funds.

If any build or website claiming to be PaperMade asks for one of those, do not proceed.

## What the extension can do

The current browser extension can:

- read supported FOMO pages so it can identify the token and visible market data;
- request public token market data from DexScreener as a fallback/reference feed;
- store simulated trading state in browser extension storage;
- communicate with the PaperMade website for approved-account/session syncing;
- sync simulated paper-trading state for signed-in approved users.

It is not designed to sign blockchain transactions or execute real trades.

## Reporting a vulnerability

Please avoid posting exploit details, access tokens, one-time login links, bot tokens, service-role keys, database passwords, private keys, or user data in a public GitHub issue.

During the private beta, report security issues through the official PaperMade community channels.

## Secrets policy

Secrets must never be committed to this repository.

Examples include:

- Discord bot tokens
- Discord client secrets
- Supabase service-role keys
- database passwords
- private keys
- one-time login links

Public browser configuration such as a Supabase publishable/anon key may be client-visible by design, but privileged server credentials must remain server-side.
