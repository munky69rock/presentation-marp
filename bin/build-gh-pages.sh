#!/bin/bash

set -ue

root_dir=$(cd $(dirname $0)/..;pwd)
sed=$(if (which gsed &> /dev/null); then echo gsed; else echo sed; fi)

list_html() {
  find public -type f -name "*.html" | grep -v index.html
}

list_all() {
  find public -type f -name "*.pdf" -o -name "*.html" | sort -r
}

replace_image_path() {
  rsync -avzq images/ public/images/
  $sed -i 's/"\.\//"..\//g' $(list_html)
}

generate_index() {
  slides=$(
    list_all | \
    $sed -e 's/public\///' -e 's/^/"/' -e 's/$/"/' | \
    $sed -z -e 's/\n/,/g' -e 's/,$//'
  ) 
  data="{\"slides\":[${slides}]}"
  yarn ejs -i "$data" index.ejs -o public/index.html
}

main() {
  cd "$root_dir"

  yarn marp
  replace_image_path
  generate_index
}

main
