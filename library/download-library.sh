#!/bin/bash

set -e

PAGE_SIZE=50
LIBRARY_SIZE=1000
LIBRARY_FOLDER="./images"
USER_AGENT="ImmichBot/0.0 (https://bo0tzz.me/; immich-bot@bo0tzz.me) library-scraper/0.0"

image_json_page () {
	curl --location --request GET "https://commons.wikimedia.org/w/api.php?action=query&format=json&uselang=en&generator=search&gsrsearch=filetype%3Abitmap%7Cdrawing%20-fileres%3A0%20fileres%3A%3E1000%20haslicense%3Aunrestricted%20haswbstatement%3AP6731%3DQ63348069%20nature&gsrlimit=$PAGE_SIZE&gsroffset=$1&gsrinfo=totalhits%7Csuggestion&gsrprop=size%7Cwordcount%7Ctimestamp%7Csnippet&prop=info%7Cimageinfo%7Centityterms&inprop=url&gsrnamespace=6&iiprop=url%7Csize%7Cmime&iiurlheight=180&wbetterms=label"
}

image_urls_page () {
	image_json_page $1 | jq -r '.query.pages[].imageinfo[].url' 
}

main () {
	cd $LIBRARY_FOLDER
	local urls=""
	for i in $(seq 0 $PAGE_SIZE $(($LIBRARY_SIZE-$PAGE_SIZE))); do
	    urls+=$(image_urls_page $i)
	    urls+=" "
	done
	echo $urls | tr " " "\n" | wget -U $USER_AGENT -i -
}

main
