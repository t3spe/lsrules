# this script adapts the rules we have to work under a linux system that runs ufw
#
# there are 2 things, creating entries in /etc/hosts and mapping them to an ip + banning that ip using ufw
#   and the 2nd thing is to ban subnets that we don't want traffic to go to / come from

SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BANPREFIX=$SELFDIR/banprefix
BANHOST=$SELFDIR/banhost
rm -rf "${BANPREFIX}"
rm -rf "${BANHOST}"

# apple block
cat $SELFDIR/noapple-lsrules/prefix >> ${BANPREFIX}
cat $SELFDIR/noapple-lsrules/prefix6 >> ${BANPREFIX}

# proxy block
cat $SELFDIR/proxy-rules/sb_unified_hosts_fakenews-gambling-social.lsrules | jq -re '.rules[]."remote-domains"' >> ${BANHOST}

# nonews block
cat $SELFDIR/nonews-lsrules/nonews.lsrules | jq -re '.rules[]."remote-domains"' >> ${BANHOST}

BANNEDIP="157.240.3.35"
NEWHOSTS=$SELFDIR/newhosts
rm -rf "${NEWHOSTS}"

SETUPSCRIPT=$SELFDIR/linux-rules-post-apply.sh
rm -rf "${SETUPSCRIPT}"

old="$IFS"
IFS='
'
for EHL in $(cat /etc/hosts)
do
    echo ${EHL} >> ${NEWHOSTS}
    if [ ${EHL} == "#====" ]
    then
        break
    fi
done

for NLH in $(cat ${BANHOST})
do
    echo "${BANNEDIP}   ${NLH}" >> ${NEWHOSTS}
done
echo "sudo mv ${NEWHOSTS} /etc/hosts" >> ${SETUPSCRIPT}

echo "sudo ufw reject in from 157.240.3.35 to any" >> ${SETUPSCRIPT}
echo "sudo ufw reject out from any to 157.240.3.35" >> ${SETUPSCRIPT}

for NLC in $(cat ${BANPREFIX})
do
    echo "sudo ufw reject in from ${NLC} to any" >> ${SETUPSCRIPT}
    echo "sudo ufw reject out from any to ${NLC}" >> ${SETUPSCRIPT}   
done

chmod +x ${SETUPSCRIPT}
echo "executing setup script"
${SETUPSCRIPT}

# cleanup
rm -rf "${BANPREFIX}"
rm -rf "${BANHOST}"
rm -rf "${NEWHOSTS}"
rm -rf "${SETUPSCRIPT}"

