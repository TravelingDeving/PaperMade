# Privacy

PaperMade is designed around a minimal-data model for a paper-trading product.

## Extension data

The extension can store simulated trading data such as:

- virtual cash balance
- selected starting bankroll
- paper positions
- paper trade history
- journal statistics
- UI size and position
- overlay transparency
- account-sync state

Guest/local records can remain in browser extension storage.

## Signed-in users

Approved users may sync their simulated trading record to the PaperMade backend so their paper-trading history can follow their account across supported PaperMade experiences.

## Discord private beta

During the private beta, Discord is used to verify access. PaperMade may store the Discord user ID and display/username needed to associate an approved tester with a PaperMade account.

## Public community features

Public PaperMade profiles and leaderboards are intended to expose PaperMade-specific simulated statistics and profile information the user chooses to publish.

Current profile/community data can include:

- display name
- Discord display/username
- profile avatar and banner
- bio
- favorite chain
- trading style
- optional public social handle
- paper-trading statistics
- leaderboard rank
- earned achievements and featured badges
- friend/connections state

These public surfaces are not intended to expose email addresses, auth UUIDs, private login links, seed phrases, private keys, or wallet credentials.

## Feedback and moderation

Approved users may submit feedback/bug reports. Staff moderation tools can expose report details needed to review those submissions. Public profile views are intended to use sanitized profile data rather than exposing private account identifiers.

## What PaperMade does not need

PaperMade does not need a wallet seed phrase, wallet private key, or custody of crypto funds.

## Real-money trading

PaperMade is a simulator. The extension is not intended to execute real trades or sign blockchain transactions.
