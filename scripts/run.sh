#!/usr/bin/env zsh

git add -A
git commit -m "(fix) windeployqt doesn't place the dll in the install/bin folder"
git tag -f v0.0.7
# git push origin main
git push origin main --tags -f