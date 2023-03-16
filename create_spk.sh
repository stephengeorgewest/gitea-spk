#!/bin/sh

# Determines the binary for which the package should be build.
select_binary()
{
    local args=$1
    local binary=""

    if [ ! "$args" = "" ]; then
        if [ -f $args ]; then
            binary=$args
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
    echo "$binary"
}


# Determines the version number of the given Gitea binary.
get_version()
{
    local binary="$1"

    echo ${binary} | sed 's/[^0-9.]*\([0-9.]*\).*/\1/'
}


# Determines the platform identifier of the given Gitea binary.
get_platform()
{
    local binary="$1"

    echo ${binary} | sed 's/.*linux-\(.*\)/\1/'
}


# Determines the Synology arch values for the given Gitea binary.
get_arch()
{
    local binary="$1"
    local platform=`get_platform $binary`

    # lookup the arch values for the given platform in the mappings file
    grep "^$platform " 'arch.desc' | awk '{for (i=2; i<=NF; i++) printf "%s ", $i}' | xargs
}


# Updates the package metadata to reflect the given Gitea binary.
update_metadata()
{
    local version="$1"
    local arch="$2"

    if [ "$arch" = "" ]; then
        echo "$binary is not a supported platform"
        exit 1
    fi

    cp 2_create_project/INFO.in 2_create_project/INFO

    sed -i -e "s/[0-9]\+\.[0-9]\+\.[0-9]\+/$version/" 2_create_project/INFO
    sed -i -e "s#arch=\".*\"#arch=\"$arch\"#" 2_create_project/INFO
}


# Builds the package for the given Gitea binary.
build()
{
    local current=$PWD
    local binary=$1

    version=`get_version $binary`
    arch=`get_arch $binary`

    update_metadata "$version" "$arch"

    chmod +x $binary
    mkdir -p 1_create_package/gitea
    ln -sf "$PWD/$binary" 1_create_package/gitea/gitea
    cd 1_create_package
    tar cvfJh ../2_create_project/package.tgz *
    cd ../2_create_project/
    tar cvf ../$binary.spk --exclude=INFO.in *
    rm -f package.tgz
    cd $current
}


binary=`select_binary $@`

build "$binary"
