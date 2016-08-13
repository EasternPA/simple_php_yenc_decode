#!/bin/sh
 
apt-get install libboost-regex-dev g++ -y
 
g++ `php-config --includes` -fpic -c source/yenc_decode_wrap.cpp
 
if [ ! -e yenc_decode_wrap.o ]; then
	echo "Error creating yenc_decode_wrap.o!"
	exit 1
fi
 
g++ -fpic -c source/yenc_decode.cpp -lboost_regex
 
if [ ! -e yenc_decode.o ]; then
	echo "Error creating yenc_decode.o!"
	exit 2
fi
 
PHP_API=`php-config --phpapi`
EXTENSIONS="/usr/lib/php/${PHP_API}"
 
if [ ! -e ${EXTENSIONS} ]; then
	echo "Error locating extensions directory ${EXTENSIONS}!"
	exit 3
fi
 
sudo g++ -shared *.o -o ${EXTENSIONS}/simple_php_yenc_decode.so -lboost_regex

rm yenc_decode.o
rm yenc_decode_wrap.o
 
if [ ! -e ${EXTENSIONS}/simple_php_yenc_decode.so ]; then
	echo "Error creating ${EXTENSIONS}/simple_php_yenc_decode.so!"
	exit 4
else
	echo "The extension was compiled successfully."
fi

if [ -e /etc/php/7.0/cli/conf.d/simple_php_yenc_decode.ini ]; then
	echo "Error: This file (/etc/php/7.0/cli/conf.d/simple_php_yenc_decode.ini) already exists, manually check if the contents look like this (change it if not): extension=${EXTENSIONS}/simple_php_yenc_decode.so"
	exit 5
else
	echo "extension=${EXTENSIONS}/simple_php_yenc_decode.so" > ./simple_php_yenc_decode.ini
	mv ./simple_php_yenc_decode.ini /etc/php/7.0/mods-available/simple_php_yenc_decode.ini
	ln -s /etc/php/7.0/mods-available/simple_php_yenc_decode.ini /etc/php/7.0/cli/conf.d/simple_php_yenc_decode.ini
	if [ ! -e /etc/php/7.0/cli/conf.d/simple_php_yenc_decode.ini ]; then
		echo "Error creating (/etc/php/7.0/cli/conf.d/simple_php_yenc_decode.ini). You can manually make this file and put this content in it: extension=${EXTENSIONS}/simple_php_yenc_decode.so"
		exit 6
	fi
	echo "Everything was successful, you should now be able to use the extension in PHP."
fi
