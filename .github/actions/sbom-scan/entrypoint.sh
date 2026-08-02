#!/bin/bash

set -e
cd /github/worspace

echo "==== Step 1: Executing Custom SBOM Creation (Syft) ===="
syft requirements.txt -o cyclonedx-json=sbom.json

echo " ==== Step 2: Executing Custom Vulnerability Detection (Grype) ===="
grype sbom.json --by-cve --fail-on critical

echo "==== Security Audit Sweeps Completed Sucessfully ===="
