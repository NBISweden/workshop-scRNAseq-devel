#! /bin/bash

## Example usage:
#   ./download-labs.sh "https://github.com/NBISweden" "workshop-scRNAseq-devel" "compiled/labs/scanpy" "labs"

orgurl="$1"
reponame="$2"
repodir="$3"
localdir="$4"


function git_sparse_clone() (
    mkdir -p ${localdir}
    git clone -n --depth=1 --filter=tree:0 ${orgurl}/${reponame} > /dev/null 2>&1
    cd ${reponame}
    git sparse-checkout set --no-cone ${repodir} > /dev/null 2>&1
    git checkout > /dev/null 2>&1
    cd - > /dev/null 2>&1
    find . -type f -name '*.ipynb' -exec mv -n {} ./${localdir}/ \;
    rm -rf ./${reponame}
)


function select_kernel() (
    notebooks=( $(find . -name "*.ipynb" -print) )
    for nb in "${notebooks[@]}"; do
        jq '.metadata.kernelspec = {"display_name": "scanpy", "language": "python", "name": "scanpy"}' ${nb} > tmp.$$.json && mv tmp.$$.json ${nb}
    done
)


function main() (
    echo "downloading files from ${orgurl}/${reponame}/${repodir} into ${localdir}/..."
    git_sparse_clone
    echo "making 'scanpy' default kernel..."
    select_kernel
)


main
