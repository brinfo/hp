#!/bin/bash

cd $(dirname $0)
echo "DDD $(date)  $0 end..."
./getokproxy.sh >>./getokproxy.out
echo "DDD $(date)  $0 add..."
git add index.html proxyall.list proxyoks.list
echo "DDD $(date)  $0 ci..."
git ci -m 'auto update'
echo "DDD $(date)  $0 push..."
git push
echo "DDD $(date)  $0 end..."

