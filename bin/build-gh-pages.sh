#!/bin/bash

set -ue

root_dir=$(cd $(dirname $0)/..;pwd)
sed=$(if (which gsed &> /dev/null); then echo gsed; else echo sed; fi)

cd "$root_dir"
yarn marp

rsync -avz images/ public/images/
$sed -i 's/"\.\//"..\//g' $(find public -type f -name "*.html")