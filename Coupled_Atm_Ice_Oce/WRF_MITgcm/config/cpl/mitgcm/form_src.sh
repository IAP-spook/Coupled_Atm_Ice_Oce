#!/bin/bash

Env=$1
Srclist=$3
source $Env

touch $Srclist
cat > $Srclist << EOF
$CODEROOT/cpl/Atm_Ice_Oce
EOF

exit 0
