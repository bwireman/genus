#!/usr/bin/bash

echo "HERE WE GO ⚡"
rm -rf types/
rm -f test_server.js
mix clean
mix
mix genus.rest E /api/e
mix genus.rest F /api/f

./node_modules/.bin/esbuild --bundle --minify --outfile=test_server.js --platform=node test/rest/server.js
node test_server.js &

mix test
yarn jest

pkill -P $$
echo "DONE ⚡"