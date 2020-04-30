# remove unnecessary parts from the TCX files
# otherwise they are not processable in R
cd C:\Users\mrm\Desktop\strava\activities

$configFiles = Get-ChildItem . *.tcx -rec

foreach ($file in $configFiles)
{
    (Get-Content $file.PSPath) |
    Foreach-Object { $_ -replace [Regex]::Escape('<?xml version="1.0" encoding="UTF-8"?>'), "" } |
    Set-Content $file.PSPath
}