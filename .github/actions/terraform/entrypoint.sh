#!/bin/bash

set -e

export STATE_KEY=${INPUT_STATE_KEY}
export TF_STAGE=${INPUT_TF_STAGE}
export DJANGO_SECRET_KEY_PROD=${INPUT_DJANGO_SECRET_KEY_PROD}

if [[ "$TF_STAGE" == "stage1" ]]; then
    terraform -chdir=${INPUT_TF_STAGE} init -backend-config="key=${INPUT_STATE_KEY}.tfstate"
    terraform -chdir=${INPUT_TF_STAGE} plan -out=${INPUT_TF_STAGE}.tfplan
    terraform -chdir=${INPUT_TF_STAGE} apply ${INPUT_TF_STAGE}.tfplan

elif [[ "$TF_STAGE" == "stage2" ]]; then
    terraform -chdir=terraform/${INPUT_TF_STAGE} init -backend-config="key=pipeline/${INPUT_STATE_KEY}-${INPUT_TF_STAGE}.tfstate"
    terraform -chdir=terraform/${INPUT_TF_STAGE} plan -out=${INPUT_TF_STAGE}.tfplan
    terraform -chdir=terraform/${INPUT_TF_STAGE} apply ${INPUT_TF_STAGE}.tfplan

fi
