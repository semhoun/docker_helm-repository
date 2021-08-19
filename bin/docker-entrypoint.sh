#!/bin/bash

set -e

export PATH=${PATH}:/opt/bin

rm -f /var/run/apache2/apache2.pid 

echo "Execute create-helm-repo.sh to create/update the repository"

$@