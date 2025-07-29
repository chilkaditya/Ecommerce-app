#!/bin/bash
set -e

rm -rf temp-repo
git clone https://github.com/chilkaditya/Ecommerce-app.git temp-repo
cd temp-repo

branch=$(git symbolic-ref --short HEAD)

git remote add azure https://$1@dev.azure.com/chilkadityadas2000/tf-sample-project/_git/sample-repo
git push azure $branch --force --set-upstream
