# custom wim

$MountDir = ".\mount"
$TmpDir = ".\tmp"

New-Item -ItemType Directory -Force -Path $MountDir
New-Item -ItemType Directory -Force -Path $TmpDir

Mount-WindowsImage -ImagePath ".\install.wim" -Index 1 -Path $MountDir

$SSU = Get-ChildItem ssu-*.msu | Select -ExpandProperty Name
$CU = Get-ChildItem cu-*.msu | Select -ExpandProperty Name

Add-WindowsPackage -PackagePath $SSU -Path $MountDir
Add-WindowsPackage -PackagePath $CU -Path $MountDir

$AppsList = "Microsoft.BingWeather",
#"Microsoft.DesktopAppInstaller",
"Microsoft.GetHelp",
"Microsoft.Getstarted",
"Microsoft.Messaging",
"Microsoft.Microsoft3DViewer",
"Microsoft.MicrosoftOfficeHub",
"Microsoft.MicrosoftSolitaireCollection",
"Microsoft.MicrosoftStickyNotes",
#"Microsoft.MSPaint",
"Microsoft.Office.OneNote",
"Microsoft.OneConnect",
#"Microsoft.People",
"Microsoft.Print3D",
#"Microsoft.SkypeApp",
#"Microsoft.StorePurchaseApp",
"Microsoft.Wallet",
#"Microsoft.WebMediaExtensions",
#"Microsoft.Windows.Photos",
#"Microsoft.WindowsAlarms",
#"Microsoft.WindowsCalculator",
#"Microsoft.WindowsCamera",
#"microsoft.windowscommunicationsapps",
"Microsoft.WindowsFeedbackHub",
"Microsoft.WindowsMaps",
#"Microsoft.WindowsSoundRecorder",
#"Microsoft.WindowsStore",
"Microsoft.Xbox.TCUI",
"Microsoft.XboxApp",
"Microsoft.XboxGameOverlay",
"Microsoft.XboxGamingOverlay",
"Microsoft.XboxIdentityProvider",
"Microsoft.XboxSpeechToTextOverlay",
"Microsoft.ZuneMusic",
"Microsoft.ZuneVideo"

ForEach ($App in $AppsList)
{ 
    $ProPackageFullName = (Get-AppxProvisionedPackage -Path $MountDir | Where {$_.Displayname -eq $App}).PackageName
 
    If ($ProPackageFullName)
    {
        Remove-AppxProvisionedPackage -Path $MountDir -PackageName $ProPackageFullName
    } 
    Else
    {
        Write-Host "[Skipping] Unable to find provisioned package: $App"
    }
}


DISM /Cleanup-Image /Image:"$MountDir" /StartComponentCleanup /ResetBase /ScratchDir:"$TmpDir"

Dismount-WindowsImage -Path $MountDir -Save -CheckIntegrity
