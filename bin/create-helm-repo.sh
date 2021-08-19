#!/bin/bash

for f in *; do
    if [ ! -d "$f" ] ; then
        continue;
    fi
	if [ ! -f "$f/Chart.yaml" ] && [ ! -f "$f/chart.yaml" ]; then
		continue;
    fi
	helm package $f
done

if [ ! -f "index.tpl" ] && [ -n "${HELM_REPOSITORY_NAME}" ] && [ -n "${HELM_REPOSITORY_URL}" ]; then
	sed \
		-e "s#HELM_REPOSITORY_NAME#${HELM_REPOSITORY_NAME}#g" \
		-e "s#HELM_REPOSITORY_URL#${HELM_REPOSITORY_URL}#g" \
		/opt/share/index.tpl > index.tpl
fi

helm repo index ./
helm repo-html

chown www-data.www-data index.html index.yaml *.tgz
