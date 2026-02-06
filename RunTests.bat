@echo off
pushd %~dp0
lua5.1 src\Tests\RunTests.lua
popd