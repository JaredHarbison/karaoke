# Status

Initial event presence is available. Hosts can generate an expiring event
access URL and six-character code; performers can enter the code to receive
presence for that event. During a live event, generating a replacement rotates
the code and revokes the previous session. The permanent venue QR remains the
stable entry point.

Owner-selectable security profiles remain post-MVP.

- To rotate a compromised event code, use the live event's “Rotate event access
  code” action. The prior URL and code stop granting presence.
- Future guide: preserve the permanent venue QR while rotating event access.
- Future guide: use host approval as an accessibility fallback.
