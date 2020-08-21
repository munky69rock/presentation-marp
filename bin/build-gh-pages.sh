#!/bin/bash

set -ue

root_dir=$(cd $(dirname $0)/..;pwd)
sed=$(if (which gsed &> /dev/null); then echo gsed; else echo sed; fi)

list_html() {
  find public -type f -name "*.html" | grep -v index.html
}

list_all() {
  find public -type f -name "*.pdf" -o -name "*.html"
}

cd "$root_dir"
yarn marp
yarn marp --pdf --allow-local-files

# 画像のパスを差し替え
rsync -avz images/ public/images/

$sed -i 's/"\.\//"..\//g' $(list_html)

# index.htmlの作成
slides=$(
  list_all | \
  $sed -e 's/public\///' -e 's/^/"/' -e 's/$/"/' | \
  $sed -z -e 's/\n/,/g' -e 's/,$//'
) 
data="{\"slides\": [${slides}]}"
npx ejs -i "$data" index.ejs -o public/index.html