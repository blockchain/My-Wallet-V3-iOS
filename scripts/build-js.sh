set -ue
cd Submodules/My-Wallet-V3

git log -1 | cat

echo "Cleaning..."
rm -rf build dist

echo "Resetting index.js..."
git checkout -- src/index.js

echo "Injecting navigator and global.crypto into index.js..."
buffer='var Buffer = require('"'"'buffer'"'"').Buffer;'
globalCrypto='global.crypto = {getRandomValues: function(intArray) {var result = objc_getRandomValues(intArray);intArray.set(new Buffer(result, '"'"'hex'"'"'));}};'
sed -i '' 's/'"$buffer"'/'"$buffer"'\'$'\n'"$globalCrypto"'/' src/index.js

echo "Building..."
npm run build

# Required for overriding methods in Objective-C
echo "Patching BitcoinJS..."
sed -i '' '/validateMnemonic: validateMnemonic/s/$/, salt: salt/' dist/my-wallet.js

echo "Build success"
