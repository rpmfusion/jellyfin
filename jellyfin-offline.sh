#!/bin/sh

JELLYFIN_VERSION=10.11.4

# Retrieve neccessary .NET NuGet packages for offline building
tar xf jellyfin-${JELLYFIN_VERSION}.tar.gz
pushd jellyfin-${JELLYFIN_VERSION}
mkdir jellyfin-nupkgs
dotnet restore --packages ./jellyfin-nupkgs
pushd jellyfin-nupkgs
#for dir in *; do for ver in $(ls $dir); do echo "Provides: bundled(dotnet-$dir) = $ver" >> ../../jellyfin-rpm-bundled.txt; done; done
popd
mkdir jellyfin-nupkgs-system
pushd jellyfin-nupkgs-system
curl -L https://www.nuget.org/api/v2/package/runtime.any.System.Collections/4.3.0 > runtime.any.system.collections.4.3.0.nupkg
curl -L https://www.nuget.org/api/v2/package/runtime.any.System.Diagnostics.Tracing/4.3.0 > runtime.any.system.diagnostics.tracing.4.3.0.nupkg
curl -L https://www.nuget.org/api/v2/package/runtime.any.System.Globalization/4.3.0 > runtime.any.system.globalization.4.3.0.nupkg
curl -L https://www.nuget.org/api/v2/package/runtime.any.System.Globalization.Calendars/4.3.0 > runtime.any.system.globalization.calendars.4.3.0.nupkg
curl -L https://www.nuget.org/api/v2/package/runtime.any.System.IO/4.3.0 > runtime.any.system.io.4.3.0.nupkg
curl -L https://www.nuget.org/api/v2/package/runtime.any.System.Reflection/4.3.0 > runtime.any.system.reflection.4.3.0.nupkg
curl -L https://www.nuget.org/api/v2/package/runtime.any.System.Reflection.Primitives/4.3.0 > runtime.any.system.reflection.primitives.4.3.0.nupkg
curl -L https://www.nuget.org/api/v2/package/runtime.any.System.Resources.ResourceManager/4.3.0 > runtime.any.system.resources.resourcemanager.4.3.0.nupkg
curl -L https://www.nuget.org/api/v2/package/runtime.any.System.Runtime/4.3.0 > runtime.any.system.runtime.4.3.0.nupkg
curl -L https://www.nuget.org/api/v2/package/runtime.any.System.Runtime.Handles/4.3.0 > runtime.any.system.runtime.handles.4.3.0.nupkg
curl -L https://www.nuget.org/api/v2/package/runtime.any.System.Runtime.InteropServices/4.3.0 > runtime.any.system.runtime.interopServices.4.3.0.nupkg
curl -L https://www.nuget.org/api/v2/package/runtime.any.System.Text.Encoding/4.3.0 > runtime.any.system.text.encoding.4.3.0.nupkg
curl -L https://www.nuget.org/api/v2/package/runtime.any.System.Text.Encoding.Extensions/4.3.0 > runtime.any.system.text.encoding.extensions.4.3.0.nupkg
curl -L https://www.nuget.org/api/v2/package/runtime.any.System.Threading.Tasks/4.3.0 > runtime.any.system.threading.tasks.4.3.0.nupkg
curl -L https://www.nuget.org/api/v2/package/runtime.unix.Microsoft.Win32.Primitives/4.3.0 > runtime.unix.microsoft.win32.primitives.4.3.0.nupkg
curl -L https://www.nuget.org/api/v2/package/runtime.unix.System.Diagnostics.Debug/4.3.0 > runtime.unix.system.diagnostics.debug.4.3.0.nupkg
curl -L https://www.nuget.org/api/v2/package/runtime.unix.System.IO.FileSystem/4.3.0 > runtime.unix.system.io.filesystem.4.3.0.nupkg
curl -L https://www.nuget.org/api/v2/package/runtime.unix.System.Net.Primitives/4.3.0 > runtime.unix.system.net.primitives.4.3.0.nupkg
curl -L https://www.nuget.org/api/v2/package/runtime.unix.System.Private.Uri/4.3.0 > runtime.unix.system.private.uri.4.3.0.nupkg
curl -L https://www.nuget.org/api/v2/package/runtime.unix.System.Runtime.Extensions/4.3.0 > runtime.unix.system.runtime.extensions.4.3.0.nupkg
curl -L https://www.nuget.org/api/v2/package/System.Private.Uri/4.3.0 > system.private.uri.4.3.0.nupkg
#for nupkg in *; do echo "bundled(dotnet-${nupkg%.4.3.0.nupkg}) = 4.3.0" >> ../../jellyfin-rpm-bundled.txt; done

popd
tar -c -I 'xz -9 -T0 --memlimit-compress=50%' -f ../jellyfin-nupkgs.tar.xz jellyfin-nupkgs
tar -c -I 'xz -9 -T0 --memlimit-compress=50%' -f ../jellyfin-nupkgs-system.tar.xz jellyfin-nupkgs-system
popd

# Retrieve neccessary NPM packages for offline building
tar xf jellyfin-web-${JELLYFIN_VERSION}.tar.gz
pushd jellyfin-web-${JELLYFIN_VERSION}
mkdir jellyfin-npm
npm config set cache ./jellyfin-npm
npm i webpack
echo y | npx update-browserslist-db@latest
npm i --package-lock-only
npm ci
npm i --cpu=x64 --os linux
npm i --cpu=arm64 --os linux
tar -c -I 'xz -9 -T0 --memlimit-compress=50%' -f ../jellyfin-npm.tar.xz jellyfin-npm
cp -p package-lock.json ../jellyfin-web-package-lock.json
popd

# rpm bundled for registry.npmjs.org
#grep resolved jellyfin-web-package-lock.json | grep -v github.com | sed 's/^[[:space:]]*"resolved": "https:\/\/registry.npmjs.org\///' | sort -u | awk -F'/-/' '{pkg = $1; sub(/\.tgz",$/, "",$2); base_pkg = pkg; sub("@.*/","",base_pkg); nvr = $2; sub(base_pkg"-","",nvr); print "Provides: bundled(nodejs-" pkg ") = " nvr;}' >> jellyfin-rpm-bundled.txt
# rpm bundled for github.com
#echo "Provides: bundled(nodejs-classlist.js) = 1.2.20180112" >> jellyfin-rpm-bundled.txt
