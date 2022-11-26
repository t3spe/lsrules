# this script clears the rules that were applied by the lra script

SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SETUPSCRIPT=$SELFDIR/linux-rules-post-clear.sh
rm -rf "${SETUPSCRIPT}"

NEWHOSTS=$SELFDIR/newhosts
rm -rf "${NEWHOSTS}"

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
echo "sudo mv ${NEWHOSTS} /etc/hosts" >> ${SETUPSCRIPT}

echo "sudo ufw --force reset" >> ${SETUPSCRIPT}
echo "sudo ufw enable" >> ${SETUPSCRIPT}

chmod +x ${SETUPSCRIPT}
echo "executing setup script"
${SETUPSCRIPT}

# cleanup
rm -rf "${NEWHOSTS}"
rm -rf "${SETUPSCRIPT}"