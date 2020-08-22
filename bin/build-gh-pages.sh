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

# 画像のパスを差し替え
rsync -avzq images/ public/images/
$sed -i 's/"\.\//"..\//g' $(list_html)

# iOS用のpolyfillをinject (https://github.com/marp-team/marpit-svg-polyfill)
$sed -i \
  's#</head>#<script src="https://cdn.jsdelivr.net/npm/@marp-team/marpit-svg-polyfill/lib/polyfill.browser.js"></script></head>#' \
  $(list_html)

# index.htmlの作成
slides=$(
  list_all | \
  $sed -e 's/public\///' -e 's/^/"/' -e 's/$/"/' | \
  $sed -z -e 's/\n/,/g' -e 's/,$//'
) 
data="{\"slides\": [${slides}]}"
npx ejs -i "$data" index.ejs -o public/index.html