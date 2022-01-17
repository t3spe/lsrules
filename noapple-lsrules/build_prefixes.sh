#!/usr/bin/env bash
export SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export PREFIX_JSON=${SELFDIR}/prefix.json
export PREFIX=${SELFDIR}/prefix
export PREFIX6=${SELFDIR}/prefix6

export OUT=${SELFDIR}/noapple.lsrules
export OUTTMP=${OUT}.tmp

# getting the prefixes
curl https://api.bgpview.io/asn/AS714/prefixes > ${PREFIX_JSON}
cat ${PREFIX_JSON} | jq -re .data.ipv4_prefixes[].parent.prefix | sort -u | grep -v null > ${PREFIX}
cat ${PREFIX_JSON} | jq -re .data.ipv6_prefixes[].parent.prefix | sort -u | grep -v null > ${PREFIX6}

# generating the list
rm -rf ${OUTTMP}
cat << EOF >> ${OUTTMP}
{
	"description" : " No more apple traffic - the little snitch way ",
	"name" : "noapple.lsrules",
	"rules" :  [
EOF

for PREF in $(cat ${PREFIX})
do
STR=$(sipcalc ${PREF} | grep "Network range" | cut -d '-' -f 2 | tr -d ' ')
ENR=$(sipcalc ${PREF} | grep "Network range" | cut -d '-' -f 3 | tr -d ' ')
cat << EOF >> ${OUTTMP}
        {
            "action" : "deny",
            "notes" : "",
            "owner" : "me",
            "process" : "any",
            "remote-addresses": "${STR}-${ENR}"
        },
EOF
done

for PREF in $(cat ${PREFIX6})
do
STR=$(sipcalc ${PREF} | grep -A 1 "Network range" | tr -d '\n' | cut -d '-' -f 2 | tr -d ' ' | tr -d '\t')
ENR=$(sipcalc ${PREF} | grep -A 1 "Network range" | tr -d '\n' | cut -d '-' -f 3 | tr -d ' ' | tr -d '\t')
cat << EOF >> ${OUTTMP}
        {
            "action" : "deny",
            "notes" : "",
            "owner" : "me",
            "process" : "any",
            "remote-addresses": "${STR}-${ENR}"
        },
EOF
done

cat << EOF >> ${OUTTMP}
        {
            "action" : "deny",
            "notes" : "",
            "owner" : "me",
            "process" : "any",
            "remote-domains": "apple.com"
        }
EOF


cat << EOF >> ${OUTTMP}
]}
EOF

cat ${OUTTMP} | jq . > ${OUT}
rm -rf ${OUTTMP}