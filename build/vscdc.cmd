@echo off
npx tsc -p %~dp0\tsconfig.json
node  %~dp0/out/vscdc.js %@
