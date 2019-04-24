#Created to check and download latest Adobe DC
#Creation date : 4-24-2019
#Creator: Alix N Hoover



#Variables to your software Share
$SCCMSource = '\\SCCM\Software\Adobe\Adobe Acrobat Reader DC'

#Variables-Mail
$MailServer = "MAIL"
$recip = "me@you.org"
$sender = "Powershell@me.org"
$subject = "Adobe DC Update"
#where you put your schedule task
$ServerName = "SCCM" 
#where you put your documentation on deploying files
$doc='onenote:///L:97C7-4482-A067-D2408C04CB35}&page-id={BB50B8D3-CA4C-4370-A5DB-D499DC35DC96}&object-id={8E78BBDC-DCBC-4A9F-9453-00D2C29AF662}&2C'

$versioncheck = (((Invoke-WebRequest https://www.adobe.com/devnet-docs/acrobatetk/tools/ReleaseNotesDC/index.html) |Select-Object -ExpandProperty Links | where {$_.outertext -like "1* Planned Update, *"} |where {$_.href -like "continuous*"}|Sort-Object -Property innerText -Descending).innerText).Split(" ")[0]
$versioncheck = $versioncheck.Replace("x",5)
$checkfolder = "$SCCMSource\$versioncheck"


IF (!(test-path $checkfolder)) {
    Write-Output "$checkfolder does not exist"
   
   $destinationfolder = "$checkfolder"
    Write-Output "Creating $destinationfolder"
    [System.IO.Directory]::CreateDirectory($destinationfolder)
  

 $latestVersion = (((Invoke-WebRequest https://www.adobe.com/devnet-docs/acrobatetk/tools/ReleaseNotesDC/index.html) |Select-Object -ExpandProperty Links | where {$_.outertext -like "1* Planned Update, *"} |where {$_.href -like "continuous*"}|Sort-Object -Property innerText -Descending).innerText).Split(" ").replace(".","")[0]
 $LatestVersion = $latestVersion.Replace("x",5)
			$URL = "http://ardownload.adobe.com/pub/adobe/reader/win/AcrobatDC/$($latestVersion)/AcroRdrDC$($LatestVersion)_en_US.exe" 
            $outfile= "InstallReaderDC.exe"


	#Download DC
			Write-Output "Downloading $outfile from $URL"
            $outfile="$checkfolder\$outfile"
            Invoke-WebRequest -Uri "$URL" -OutFile $outfile
  
    
#sendemail
Write-Output "Downloads Completed, Sending Email"

$body ="<html></body> <BR> Adobe DC Version <p style='color:#FF0000'>  $versioncheck </p> is ready for deployment Via SCCM  <BR>"

$body+= "<a href=$doc>Here are Directions</a> "
$body+="<BR> this is a Scheduled task on $ServerName"
 
Send-MailMessage -From $sender -To $recip -Subject $subject -Body ( $Body | out-string ) -BodyAsHtml -SmtpServer $MailServer
}

    ELSE { Write-Output "$checkfolder already exists"}
