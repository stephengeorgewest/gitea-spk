#!/bin/sh

if [ ! $# -eq 0 ]; then
    if [ -f $1 ]; then
        binary=$1
    else
        echo "$1 not found"
        exit 1
    fi
else
    # pick the latest binary
    binary=$(ls -1 -t gitea-*-linux-*[!.spk] 2>/dev/null | head -1)

    if [ ! $? -eq 0 ]; then
        echo "No gitea binary found. Please download a binary from https://github.com/go-gitea/gitea/releases"
        exit 1
    fi
fi

version=$(echo ${binary} | sed 's/[^0-9.]*\([0-9.]*\).*/\1/')

# update the package meta data to match the binary version
cp 2_create_project/INFO.in 2_create_project/INFO
sed -i -e "s/[0-9]\+\.[0-9]\+\.[0-9]\+/$version/" 2_create_project/INFO

chmod +x $binary
mkdir -p 1_create_package/gitea
ln -sf "$PWD/$binary" 1_create_package/gitea/gitea
cd 1_create_package
tar cvfhz ../2_create_project/package.tgz *
cd ../2_create_project/
tar cvfz ../$binary.spk --exclude=INFO.in *
rm -f package.tgz

