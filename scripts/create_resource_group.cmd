@echo off
:: Create resource group.  List available regions.
::
::     az account list-locations
::
set LOCATION=westeurope

:: List existing resource groups.
::
::     az group list
::
set RG_NAME=pelleo-tensorflow-rg

az group create ^
   -n %RG_NAME% ^
   -l %LOCATION%
