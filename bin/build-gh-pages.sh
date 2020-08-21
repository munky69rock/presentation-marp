#!/bin/bash

set -ue

root_dir=$(cd $(dirname $0)/..;pwd)
sed=$(if (which gsed &> /dev/null); then echo gsed; else echo sed; fi)

list_html() {
  find public -type f -name "*.html" | grep -v index.html
}

cd "$root_dir"
yarn marp

# 画像のパスを差し替え
rsync -avz images/ public/images/

$sed -i 's/"\.\//"..\//g' $(list_html)

# index.htmlの作成
slides=$(
  list_html | \
  $sed -e 's/public\///' -e 's/^/"/' -e 's/$/"/' | \
  $sed -z -e 's/\n/,/g' -e 's/,$//'
) 
data="{\"slides\": [${slides}]}"
echo $data | yarn -s run mustache - index.mustache > public/index.html