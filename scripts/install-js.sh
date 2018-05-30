set -ue
cd Submodules/My-Wallet-V3

git log -1 | cat

echo "Cleaning node_modules..."
rm -rf node_modules

echo "Installing node_modules..."
yarn --ignore-engines

# Required for JavaScriptCore
echo "Patching fetch..."
sed -i '' '1s/^/global.self = global;/' node_modules/whatwg-fetch/fetch.js

echo "Install success"
