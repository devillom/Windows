@echo off
setlocal

rem See the "Incompressible Data" section of:
rem http://www.mattmahoney.net/dc/

mawk "BEGIN { i=1; while(i<=50) { r=25+int(20 * rand()); print 'sharnd.32.exe Test-Key 'r'000000 && ren sharnd.out file'i++'.dat' } }" | cmd
