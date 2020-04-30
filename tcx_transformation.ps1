# remove unnecessary parts from the TCX files
# otherwise they are not processable in R
# navigate to the "activities" directory where you unzipped the strava bulk export 
cd C:\Users\...\strava\activities

# get list of files for looping
$configFiles = Get-ChildItem . *.tcx -rec

# remove unnecessary header
foreach ($file in $configFiles)
{
    (Get-Content $file.PSPath) |
    Foreach-Object { $_ -replace [Regex]::Escape('<?xml version="1.0" encoding="UTF-8"?>'), "" } |
    Set-Content $file.PSPath
}
