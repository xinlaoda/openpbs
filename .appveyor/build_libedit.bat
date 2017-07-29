@echo off
REM Copyright (C) 1994-2017 Altair Engineering, Inc.
REM For more information, contact Altair at www.altair.com.
REM
REM This file is part of the PBS Professional ("PBS Pro") software.
REM
REM Open Source License Information:
REM
REM PBS Pro is free software. You can redistribute it and/or modify it under the
REM terms of the GNU Affero General Public License as published by the Free
REM Software Foundation, either version 3 of the License, or (at your option) any
REM later version.
REM
REM PBS Pro is distributed in the hope that it will be useful, but WITHOUT ANY
REM WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
REM PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
REM
REM You should have received a copy of the GNU Affero General Public License along
REM with this program.  If not, see <http://www.gnu.org/licenses/>.
REM
REM Commercial License Information:
REM
REM The PBS Pro software is licensed under the terms of the GNU Affero General
REM Public License agreement ("AGPL"), except where a separate commercial license
REM agreement for PBS Pro version 14 or later has been executed in writing with Altair.
REM
REM Altair’s dual-license business model allows companies, individuals, and
REM organizations to create proprietary derivative works of PBS Pro and distribute
REM them - whether embedded or bundled with other software - under a commercial
REM license agreement.
REM
REM Use of Altair’s trademarks, including but not limited to "PBS™",
REM "PBS Professional®", and "PBS Pro™" and Altair’s logos is subject to Altair's
REM trademark licensing policies.

@echo on
setlocal

call "%~dp0set_paths.bat"

cd "%BUILDDIR%"

if not defined LIBEDIT_VERSION (
    echo "Please set LIBEDIT_VERSION to editline version!"
    exit /b 1
)

if exist "%BINARIESDIR%\libedit" (
    echo "%BINARIESDIR%\libedit exist already!"
    exit /b 0
)

if not exist "%BUILDDIR%\wineditline-%LIBEDIT_VERSION%.zip" (
    "%CURL_BIN%" -qkL -o "%BUILDDIR%\wineditline-%LIBEDIT_VERSION%.zip" https://sourceforge.net/projects/mingweditline/files/wineditline-%LIBEDIT_VERSION%.zip/download
    if not exist "%BUILDDIR%\wineditline-%LIBEDIT_VERSION%.zip" (
        echo "Failed to download libedit"
        exit /b 1
    )
)

2>nul rd /S /Q "%BUILDDIR%\wineditline-%LIBEDIT_VERSION%"
"%UNZIP_BIN%" -q "%BUILDDIR%\wineditline-%LIBEDIT_VERSION%.zip"
if not %ERRORLEVEL% == 0 (
    echo "Failed to extract %BUILDDIR%\wineditline-%LIBEDIT_VERSION%.zip"
    exit /b 1
)
if not exist "%BUILDDIR%\wineditline-%LIBEDIT_VERSION%" (
    echo "Could not find %BUILDDIR%\wineditline-%LIBEDIT_VERSION%"
    exit /b 1
)

2>nul rd /S /Q "%BUILDDIR%\wineditline-%LIBEDIT_VERSION%\build"
2>nul rd /S /Q "%BUILDDIR%\wineditline-%LIBEDIT_VERSION%\bin32"
2>nul rd /S /Q "%BUILDDIR%\wineditline-%LIBEDIT_VERSION%\lib32"
2>nul rd /S /Q "%BUILDDIR%\wineditline-%LIBEDIT_VERSION%\include"
mkdir "%BUILDDIR%\wineditline-%LIBEDIT_VERSION%\build"

"%MSYSDIR%\bin\bash" --login -i -c "cd \"$BUILDDIR_M/wineditline-$LIBEDIT_VERSION/build\" && $CMAKE_BIN -DLIB_SUFFIX=32 -G \"MSYS Makefiles\" .."
if not %ERRORLEVEL% == 0 (
    echo "Failed to generate makefiles for libedit"
    exit /b 1
)
"%MSYSDIR%\bin\bash" --login -i -c "cd \"$BUILDDIR_M/wineditline-$LIBEDIT_VERSION/build\" && make"
if not %ERRORLEVEL% == 0 (
    echo "Failed to compile libedit"
    exit /b 1
)
"%MSYSDIR%\bin\bash" --login -i -c "cd \"$BUILDDIR_M/wineditline-$LIBEDIT_VERSION/build\" && make install"
if not %ERRORLEVEL% == 0 (
    echo "Failed to install libedit"
    exit /b 1
)
"%MSYSDIR%\bin\bash" --login -i -c "mkdir -p \"$BINARIESDIR_M/libedit\" && cd \"$BUILDDIR_M/wineditline-$LIBEDIT_VERSION/\" && cp -rfv bin32 include lib32 \"$BINARIESDIR_M/libedit/\""
if not %ERRORLEVEL% == 0 (
    echo "Failed to copy bin32, include and lib32 from %BUILDDIR%\wineditline-%LIBEDIT_VERSION% to %BINARIESDIR%\libedit"
    exit /b 1
)

exit /b 0

