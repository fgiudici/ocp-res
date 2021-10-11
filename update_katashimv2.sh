#!/bin/bash

NEW_SHIMV2="http://file.rdu.redhat.com/~fgiudici/kata/containerd-shim-kata-v2"
SHIMV2_BIN="/usr/bin/containerd-shim-kata-v2"
BKUP_SUFF="-orig"

NODES=${NODES:-$1}

### Usage
if [ -z "$NODES" ]; then
    echo "Usage: $0 ALL"
    echo "   or: $0 \"<node1> <node2> ... <nodeN>\""
    exit 0
fi

if [ "$NODES" = "ALL" ]; then
    KUB_NODES=$(kubectl get node --selector='!node-role.kubernetes.io/master' --output=name)
    NODES=""

    echo "Going to replace ${SHIMV2_BIN} in the following worker nodes:"
    for i in ${KUB_NODES}; do
        node=${i#node/}
        echo "* $node"
        NODES="${NODES} ${node}"
    done
    read -n 1 -s -r -p "stop with CTRL-C or press a key to continue..."
    echo
fi

for node in ${NODES}
do
    echo "--- NODE ${node} ---"

    oc debug node/$node << EOF
chroot /host
mount -n -o remount,rw /usr/

[ -f "${SHIMV2_BIN}${BKUP_SUFF}" ] || mv "${SHIMV2_BIN}" "${SHIMV2_BIN}${BKUP_SUFF}"
curl "${NEW_SHIMV2}" --output "${SHIMV2_BIN}"
chmod 755 "${SHIMV2_BIN}"
chcon -t container_runtime_exec_t "${SHIMV2_BIN}"

mkdir /etc/kata-containers
cp /usr/share/kata-containers/defaults/configuration.toml /etc/kata-containers/

sleep 1
containerd-shim-kata-v2 --version
EOF

    echo "--- --- --- ---"
    echo
done
