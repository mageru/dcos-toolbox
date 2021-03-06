#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

dcos security org service-accounts create -p marathon-lb-public-key.pem \
    -d "dcos_marathon_lb service account" dcos_marathon_lb 2>/dev/null || true

curl -fskSL -X PUT -H 'Content-Type: application/json' -d '{"description": "Marathon Services"}' -H "Authorization: token=$(dcos config show core.dcos_acs_token)" "$(dcos config show core.dcos_url)/acs/api/v1/acls/dcos:service:marathon:marathon:services:%252F" || true
curl -fskSL -X PUT -H 'Content-Type: application/json' -d '{"description": "Marathon Events"}' -H "Authorization: token=$(dcos config show core.dcos_acs_token)" "$(dcos config show core.dcos_url)/acs/api/v1/acls/dcos:service:marathon:marathon:admin:events" || true

curl -fskSL -X PUT -H "Authorization: token=$(dcos config show core.dcos_acs_token)" "$(dcos config show core.dcos_url)/acs/api/v1/acls/dcos:service:marathon:marathon:services:%252F/users/dcos_marathon_lb/read" || true
curl -fskSL -X PUT -H "Authorization: token=$(dcos config show core.dcos_acs_token)" "$(dcos config show core.dcos_url)/acs/api/v1/acls/dcos:service:marathon:marathon:admin:events/users/dcos_marathon_lb/read" || true

dcos security secrets create-sa-secret marathon-lb-private-key.pem dcos_marathon_lb marathon-lb 2>/dev/null || true

dcos package install --options=marathon-lb-secret-options.json --yes marathon-lb
