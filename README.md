# AWS
---
## assumeCLI
(Right now it's very prone to errors and doesn't handle "piping" commands properly). Works like a charm for direct AWS commands

Run: `sh assumeCLI.sh arn:aws:iam::<TrustingAccount-ID>:role/assumeRole-RoleName`

The new prompt will contain the Trusting account ID, for example: `[AWS 123456789012> ]`
