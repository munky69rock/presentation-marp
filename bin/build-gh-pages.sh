#!/bin/bash

set -ue

root_dir=$(cd $(dirname $0)/..;pwd)
sed=$(if (which gsed &> /dev/null); then echo gsed; else echo sed; fi)
polyfill='<script src="https://cdn.jsdelivr.net/npm/@marp-team/marpit-svg-polyfill/lib/polyfill.browser.js"></script>'

list_html() {
  find public -type f -name "*.html" | grep -v index.html
}

list_all() {
  find public -type f -name "*.pdf" -o -name "*.html"
}

replace_image_path() {
  rsync -avzq images/ public/images/
  $sed -i 's/"\.\//"..\//g' $(list_html)
}

inject_polyfill() {
  # iOS用のpolyfillをinject (https://github.com/marp-team/marpit-svg-polyfill)
  $sed -i \
    "s#</head>#${polyfill}</head>#" \
    $(list_html)
}

generate_index() {
  slides=$(
    list_all | \
    $sed -e 's/public\///' -e 's/^/"/' -e 's/$/"/' | \
    $sed -z -e 's/\n/,/g' -e 's/,$//'
  ) 
  data="{\"slides\": [${slides}]}"
  yarn ejs -i "$data" index.ejs -o public/index.html
}

main() {
  cd "$root_dir"

  yarn marp
  replace_image_path
  inject_polyfill
  generate_index
}

main
