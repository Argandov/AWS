# AWS
---
## assumeCLI

Run: `sh assumeCLI.sh arn:aws:iam::<TrustingAccount-ID>:role/assumeRole-RoleName`

### What's this, and what's it for?

It's exactly like [Switching Roles](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-console.html) but using the CLI. Our already configured account will try to assume a role under the specified profile we set in the `PROFILE` variable in the script, of the "Trusing" Account ([Reference for how to set this up between accounts](https://docs.logrhythm.com/docs/OCbeats/aws-s3-beat/aws-s3-beat-with-sts-assume-role/aws-cross-account-access-using-sts-assume-role)), for the time duration in seconds we specify in `SESSION_DURATION` variable (This is limited by the "Trusting" account's Role policy).

This will spawn a (Very unstable) shell with the Trusting account ID, for example: `[AWS 123456789012> ]`. It can receive bash commands or whatever we already had in our Environment since we're just running Bash with AWS CLI assuming a different role. It's very unstable and doesn't handle any piping so it's better to spawn a shell by `/bin/bash` manually, once we assumed the role

Note: After assuming the role, customize the shell prompt temporarilly by `export PS1='New_Prompt> '` so we don't forget we're on a "special" shell.

How it looks: 

`[AWS 123456789012> ] aws s3 ls`

`[AWS 123456789012> ] aws sts get-caller-identity`

`[AWS 123456789012> ] /bin/bash`

`user@hostname:~$ export PS1='ASSUMED_ROLE >'`

`ASSUMED_ROLE > aws lambda list-functions | jq ".Functions | group_by(.Runtime)|[.[]|{ runtime:.[0].Runtime, functions:[.[]|.FunctionName] }
]"`
