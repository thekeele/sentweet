echo "Get Prod Deps"
mix deps.get --only prod

echo "Compile App"
MIX_ENV=prod mix compile

echo "Build assets"
npm install --prefix assets
npm run deploy --prefix assets
MIX_ENV=prod mix phx.digest

echo "Build Release"
MIX_ENV=prod mix release --overwrite
