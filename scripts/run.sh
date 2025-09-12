#!/usr/bin/env zsh

git add -A
git commit -m "(feat) install boost"
git tag -f v0.0.7
# git push origin main
git push origin main --tags -f