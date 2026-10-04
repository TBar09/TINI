@echo off

haxe --library tini --run BasicTypesTest.hx
echo.

haxe --library tini --run NewTypesTest.hx
echo.

haxe --library tini --run GroupTest.hx
echo.

haxe --library tini --run StringTest.hx
echo.

haxe --library tini --run ClassesTest.hx
echo.

haxe --library tini --run EnumsTest.hx
echo.

haxe --library tini --run CustomRulesTest.hx
echo.

pause