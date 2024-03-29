#!/bin/sh

# ACCOUNT A: "Trusting Account" - The acocunt that allows assume role (To account B)
# ACCOUNT B: "Trusted Account"

if [ $# -lt 2 ]
  then
    echo "[X] USAGE: assumeRole_creator.sh <TRUSTING-ACCOUNT-FULL-ROLE_ARN> <PROFILE-NAME>"
        exit 1
fi

# VARIABLES
ACCOUNT_A_ROLE_NAME='<AUDITED-ACCOUNT-ROLE-TO-ASSUME>' # MANDATORY - Audited account's trusting Role
ACCOUNT_B_SESSION_NAME='<SESSION-NAME>' # MANDATORY - Name for assume-role session name
SESSION_DURATION='3200' # Time in seconds for assume-role session duration
ACCOUNT_B_GROUP_NAME='<GROUP-NAME>' # MANDATORY - Valid Group, authorized to assumeRole
ACCOUNT_B_POLICY_FILE='demo-policy.json' # This file will be temporary. Created and eliminated during execution of this program.
PROFILE="--profile $2" # ESTA VARIABLE NO SE USA (ARREGLAR: LA EJECUCION ESTA CORRIENDO BAJO "default" SIEMPRE)

# TO-DO:
# Catch commands globally (Right now piping is not allowed)

#       ASSUME-ROLE AND EXECUTE AWS CLI
# 1.- Sanity check: Check necessary programs
# 2.- generate policy JSON file
# 3.- assume-role && put creds into vars

# Argument checker

_CHECK_PROGRAM () {
                echo "[i] Checking if $1 is installed and on the user's path..."
                sleep 0.3
                which $1
}

_CHECK_PROGRAM aws
_CHECK_PROGRAM jq

# 1.- GENERATE JSON POLICY
POLICY_FILE="demo-policy.json" # Output File (Modify this for a recognizable policy file)


# Processing argument & building JSON object
ROLE_ARN=$1
json=$(cat <<-END
    {
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": ["sts:AssumeRole"],
    "Resource": "$ROLE_ARN"
  }]
    }
END
)

echo $json > $POLICY_FILE && echo "Created $POLICY_FILE" # (Writing JSON to a new file)


aws $PROFILE iam put-group-policy \
                --group-name $ACCOUNT_B_GROUP_NAME \
                --policy-name Demo-assumeRole \
                --policy-document file://$ACCOUNT_B_POLICY_FILE

ACCOUNT_B_POLICY_JSON=$(cat $ACCOUNT_B_POLICY_FILE)
ACCOUNT_A_ID=$(echo $ACCOUNT_B_POLICY_JSON | sed 's/"//g' | sed 's/ /\n/g' | grep arn | sed 's/:/ /g' | awk '{print $4}')

# Change profile name (Default)
OUTPUT_FORMAT="--output json" # Format for JQ
ROLE_CREDS=$(aws $PROFILE sts assume-role --role-arn arn:aws:iam::$ACCOUNT_A_ID:role/$ACCOUNT_A_ROLE_NAME --role-session-name $ACCOUNT_B_SESSION_NAME --duration-seconds $SESSION_DURATION $OUTPUT_FORMAT) && echo "[+] Success assuming Role" || { echo "[-] ERROR assuming role. Exiting..."; exit 1; }

# VOLVER A DEJAR ESTO
#export AWS_ACCESS_KEY_ID=$(echo "$ROLE_CREDS" | jq -r .Credentials.AccessKeyId)
#export AWS_SECRET_ACCESS_KEY=$(echo "$ROLE_CREDS" | jq -r .Credentials.SecretAccessKey)
#export AWS_SESSION_TOKEN=$(echo "$ROLE_CREDS" | jq -r .Credentials.SessionToken)

echo "[i] Entering AWS CLI" # DEBUG
echo "[i] Example: Run \"aws sts get-caller-identity\"" # DEBUG
rm $POLICY_FILE && echo "Deleted $POLICY_FILE"
#
#while read -p "[AWS $ACCOUNT_A_ID> ] " MY_COMMAND
#do
#               $MY_COMMAND
#done
# TEST ZONE
env AWS_SESSION_TOKEN=$(echo "$ROLE_CREDS" | jq -r .Credentials.SessionToken) env AWS_SECRET_ACCESS_KEY=$(echo "$ROLE_CREDS" | jq -r .Credentials.SecretAccessKey) env AWS_ACCESS_KEY_ID=$(echo "$ROLE_CREDS" | jq -r .Credentials.AccessKeyId) env PS1="[ AWS $ACCOUNT_A_ID ] > " bash --noprofile --norc
