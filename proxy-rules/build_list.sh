#!/usr/bin/env bash
export SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ORIGIN="https://raw.githubusercontent.com/naveednajam/Little-Snitch---Rule-Groups/master/unified_hosts_fakenews-gambling-social/sb_unified_hosts_fakenews-gambling-social.lsrules"
RAW_FILE="raw.lsrules"
echo "retrieving origin file ${ORIGIN}"
wget -O ${SELFDIR}/${RAW_FILE} ${ORIGIN}
echo "masking linkedin and reddit..."
# this could be done better by removing the rules - but keep it simple for now
cat ${SELFDIR}/${RAW_FILE} | sed 's/linkedin/masked001linkedin/' | sed 's/\.licdn/\.masked003/' | sed 's/reddit/masked002reddit/' | sed 's/redd\.it/masked004red\.it/' >  ${SELFDIR}/sb_unified_hosts_fakenews-gambling-social.lsrules
echo "done"
