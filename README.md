# AWS
---
## assumeCLI

Run: `sh assumeCLI.sh arn:aws:iam::<TrustingAccount-ID>:role/assumeRole-RoleName`

What's this?
([Example](https://docs.logrhythm.com/docs/OCbeats/aws-s3-beat/aws-s3-beat-with-sts-assume-role/aws-cross-account-access-using-sts-assume-role))

What for?

- 

(Right now it's very prone to errors and doesn't handle "piping" commands properly. Best to spawn /bin/bash manually to get a stable shell).


The new prompt will contain the Trusting account ID, for example: `[AWS 123456789012> ]`

Usage: 

`[AWS 123456789012> ] aws s3 ls`

`[AWS 123456789012> ] aws sts get-caller-identity`

It also accepts Bash commands, since we're basically just running Bash with temporary Env Vars (AWS Temporary STS tokens)
