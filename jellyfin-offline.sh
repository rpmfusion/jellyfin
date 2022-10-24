#!/bin/sh

JELLYFIN_VERSION=10.8.5
DOTNET_VERSION=6.0.9
DOTNET_HOST_VERSION=6.0.9

# Retrieve neccessary .NET NuGet packages for offline building
tar xf jellyfin-${JELLYFIN_VERSION}.tar.gz
pushd jellyfin-${JELLYFIN_VERSION}
mkdir jellyfin-nupkgs
dotnet restore --packages ./jellyfin-nupkgs
mkdir jellyfin-nupkgs2
pushd jellyfin-nupkgs2
curl -L https://www.nuget.org/api/v2/package/runtime.any.System.Globalization/4.3.0 > runtime.any.system.globalization.4.3.0.nupkg
curl -L https://www.nuget.org/api/v2/package/runtime.any.System.Runtime/4.3.0 > runtime.any.system.runtime.4.3.0.nupkg
curl -L https://www.nuget.org/api/v2/package/Microsoft.NETCore.App.Runtime.linux-x64/${DOTNET_VERSION} >  microsoft.netcore.app.runtime.linux-x64.${DOTNET_VERSION}.nupkg
curl -L https://www.nuget.org/api/v2/package/Microsoft.NETCore.App.Host.linux-x64/${DOTNET_HOST_VERSION} >  microsoft.netcore.app.host.linux-x64.${DOTNET_HOST_VERSION}.nupkg
curl -L https://www.nuget.org/api/v2/package/Microsoft.AspNetCore.App.Runtime.linux-x64/${DOTNET_VERSION} > microsoft.aspnetcore.app.runtime.linux-x64.${DOTNET_VERSION}.nupkg
curl -L https://www.nuget.org/api/v2/package/System.Private.Uri/4.3.0 > system.private.uri.4.3.0.nupkg
curl -L https://www.nuget.org/api/v2/package/runtime.unix.System.Private.Uri/4.3.0 > runtime.unix.system.private.uri.4.3.0.nupkg
popd
tar -c -I 'xz -9 -T0' -f ../jellyfin-nupkgs.tar.xz jellyfin-nupkgs
tar -c -I 'xz -9 -T0' -f ../jellyfin-nupkgs2.tar.xz jellyfin-nupkgs2
popd

# Retrieve neccessary NPM packages for offline building
tar xf jellyfin-web-${JELLYFIN_VERSION}.tar.gz
pushd jellyfin-web-${JELLYFIN_VERSION}
mkdir jellyfin-npm
npm config set cache ./jellyfin-npm
npm ci
npm i --package-lock-only
tar -c -I 'xz -9 -T0' -f ../jellyfin-npm.tar.xz jellyfin-npm
cp -p package-lock.json ../jellyfin-web-package-lock.json
popd

