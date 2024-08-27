REM Description: Install Intel Support Packages on Windows
REM BKM reference: https://www.intel.com/content/www/us/en/developer/articles/tool/pytorch-prerequisites-for-intel-gpu/2-5.html
REM To-do: Add driver installation in this file.

set XPU_PARENT_DIR=C:\Program Files (x86)\Intel
set XPU_PYTORCH_BUNDLE_URL=https://registrationcenter-download.intel.com/akdlm/IRC_NAS/9d1a91e2-e8b8-40a5-8c7f-5db768a6a60c/w_intel-for-pytorch-gpu-dev_p_0.5.3.37_offline.exe
set XPU_BUNDLE_VERSION="0.5.3+31"
set XPU_PYTORCH_BUNDLE_DISPLAY_NAME=intel.oneapi.win.intel-for-pytorch-gpu-dev.product
set XPU_PTI_URL=https://registrationcenter-download.intel.com/akdlm/IRC_NAS/9d1a91e2-e8b8-40a5-8c7f-5db768a6a60c/w_intel-pti-dev_p_0.9.0.37_offline.exe
set XPU_PTI_VERSION="0.9.0+36"
set XPU_PTI_PRODUCT_NAME=intel.oneapi.win.intel-pti-dev.product
set INSTALL_FRESH_BUNDLE=0
set INSTALL_FRESH_PTI=0

REM Check if oneAPI is already installed
if not exist "%XPU_PARENT_DIR%\Installer\installer.exe" (
    set INSTALL_FRESH_BUNDLE=1
    set INSTALL_FRESH_PTI=1
)

REM Check if oneAPI is latest version
"%XPU_PARENT_DIR%\oneAPI\Installer\installer.exe" --list-products > tmp_bundle_uninstall_version.log
for /f "tokens=1,2" %%a in (tmp_bundle_uninstall_version.log) do (
    if "%%a"=="%XPU_PYTORCH_BUNDLE_DISPLAY_NAME%" (
        echo %%a Installed Version: %%b
        set "CURRENT_BUNDLE_VERSION=%%b"
    )
    if "%%a"=="%XPU_PTI_PRODUCT_NAME%" (
        echo %%a Installed Version: %%b
        set "CURRENT_PTI_VERSION=%%b"
)
)

if not "%CURRENT_BUNDLE_VERSION%"=="% XPU_BUNDLE_VERSION%" (
    set INSTALL_FRESH_ONEAPI=1
)

if not "%CURRENT_PTI_VERSION%"=="% XPU_PTI_VERSION%" (
    set INSTALL_FRESH_PTI=1
)

if "%INSTALL_FRESH_ONEAPI%"=="1" (
    IF EXIST "%XPU_PARENT_DIR%\oneAPI\Installer\installer.exe" (
        "%XPU_PARENT_DIR%\oneAPI\Installer\installer.exe" --list-products > oneapi_products_before_uninstall.log
        IF EXIST tmp_oneapi_uninstall_version.log (
            del tmp_oneapi_uninstall_version.log
        )
    
        "%XPU_PARENT_DIR%\oneAPI\Installer\installer.exe" --list-products > tmp_oneapi_uninstall_version.log
        for /f "tokens=1,2" %%a in (tmp_oneapi_uninstall_version.log) do (
            if "%%a"=="%XPU_PYTORCH_BUNDLE_DISPLAY_NAME%" (
                echo Version: %%b
                start /wait "Intel Pytorch Bundle Uninstaller" "%XPU_PARENT_DIR%\oneAPI\Installer\installer.exe" --action=remove --eula=accept --silent --product-id %XPU_PYTORCH_BUNDLE_DISPLAY_NAME% --product-ver %%b --log-dir uninstall_bundle
            )
        )
    
        IF EXIST tmp_oneapi_uninstall_version.log (
            del tmp_oneapi_uninstall_version.log
        )
        if errorlevel 1 exit /b
        if not errorlevel 0 exit /b
    )

    curl -o xpu_bundle.exe --retry 3 --retry-all-errors -k %XPU_PYTORCH_BUNDLE_URL%
    start /wait "Intel Pytorch Bundle Installer" "xpu_bundle.exe" --action=install --eula=accept --silent --log-dir install_bundle
    if errorlevel 1 exit /b
    if not errorlevel 0 exit /b
    del xpu_bundle.exe
)

if "%INSTALL_FRESH_PTI%"=="1" (
    IF EXIST "%XPU_PARENT_DIR%\oneAPI\Installer\installer.exe" (
        "%XPU_PARENT_DIR%\oneAPI\Installer\installer.exe" --list-products > oneapi_products_before_uninstall.log
        IF EXIST tmp_oneapi_uninstall_version.log (
            del tmp_oneapi_uninstall_version.log
        )
    
        "%XPU_PARENT_DIR%\oneAPI\Installer\installer.exe" --list-products > tmp_oneapi_uninstall_version.log
        for /f "tokens=1,2" %%a in (tmp_oneapi_uninstall_version.log) do (
            if "%%a"=="%XPU_PTI_PRODUCT_NAME%" (
                echo Version: %%b
                start /wait "Intel PTI Uninstaller" "%XPU_PARENT_DIR%\oneAPI\Installer\installer.exe" --action=remove --eula=accept --silent --product-id %XPU_PTI_PRODUCT_NAME% --product-ver %%b --log-dir uninstall_pti
            )
        )
    
        IF EXIST tmp_oneapi_uninstall_version.log (
            del tmp_oneapi_uninstall_version.log
        )
        if errorlevel 1 exit /b
        if not errorlevel 0 exit /b
    )

    curl -o xpu_pti.exe --retry 3 --retry-all-errors -k %XPU_PTI_URL%
    start /wait "Intel PTI Installer" "xpu_pti.exe" --action=install --eula=accept --silent --log-dir install_pti
    if errorlevel 1 exit /b
    if not errorlevel 0 exit /b
    del xpu_pti.exe
)
