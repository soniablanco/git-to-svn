#!/bin/bash

set -e




rm -r -f target_folder
rm -r -f svn_source
svn checkout --username $SVN_USERNAME --password $SVN_PASSWORD  --non-interactive $1 svn_source
cd svn_source
previousHash=""
if [ -f syncHash.ddl ]
then
   previousHash=$(cat syncHash.ddl)
fi
cd ..

cd git_source
currentHash=$(git rev-parse HEAD)
changelog=$(git log --oneline $previousHash...$currentHash)
echo $changelog
echo "$currentHash" > syncHash.ddl
cd ..
echo $previousHash
echo $currentHash

mkdir target_folder
mkdir target_folder/.svn

cp -a svn_source/.svn/. target_folder/.svn/
cp -a git_source/. target_folder/
rm -r target_folder/.git

rm -r svn_source

cd target_folder
if [[ ! -z $(svn status) ]]; then
    echo "there are files"
    
    delparams=$(svn st | grep ^! | cut -b9- | sed 's/^/"/;s/$/"/')
        echo $delparams
        if [[ ! -z "${delparams// }" ]]; then
            svn st | grep ^! | cut -b9- | sed 's/^/"/;s/$/"/' | xargs svn delete
        fi
    svn add --force .
    echo "$changelog" > changelog.txt
    svn commit --username $SVN_USERNAME --password $SVN_PASSWORD  --non-interactive  --file changelog.txt
    rm changelog.txt    
else
    echo "no files found"
fi

if [[ $(svn status) ]]; then
    echo "Error still files!" 1>&2
    exit 64
else
    echo "suceeded"
fi
cd ..
rm -r target_folder
