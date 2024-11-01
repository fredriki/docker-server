#!/bin/bash

mkdir wikmd

#########################
# AUTHELIA ACCESS RULES #
#########################

SERVICE_NAME=wiki
ACCESS_RULES_FILE="auth/authelia/access_rules.yml"

# Define the new access rule
new_rule="
    - domain: ${SERVICE_NAME}.${MYDOMAIN}
      subject: "group:${SERVICE_NAME}"
      policy: one_factor
"

echo "$new_rule" >> "$ACCESS_RULES_FILE"