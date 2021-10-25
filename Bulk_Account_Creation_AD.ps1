#Grabs CSV file
$filePath = Read-Host "Enter CSV filepath"
$ADUsers = Import-csv $filePath
Write-Host "Importing $filePath"
Start-Sleep -Seconds 2
Import-Module activedirectory

Write-Host "Creating users......"
$counter = 0
Start-Sleep -Seconds 2

#creates var for each column 
foreach ($user in $ADUsers) {
	
	
	$Username = $User.username
	$Password = $User.password
	$Firstname = $User.firstname
	$Lastname = $User.lastname
	$OU = "OU=WMA,OU=Users,OU=company,DC=domain,DC=int"
	$email = $User.email
	$phone = $User.phone
	$jobtitle = $User.jobtitle
	$company = $User.company
	$department = $User.department
	$proxyAddresses = "SMTP:$Username@domain.com", "smtp:$Username@domain.onmicrosoft.com", "smptp:$Username@domain.mail.onmicrosoft.com", "smtp:$Username@domain2.com"


#checks if username is already in AD
	if (Get-ADUser -F {SamAccountName -eq $Username}){

	Write-Warning "A user account with username $Username already exist in Active Directory."


	}
	else{

		New-ADUser `
		-SamAccountName $Username `
		-UserPrincipalName "$Username@BSBDesign.com" `
		-Name "$Firstname $Lastname" `
		-GivenName $Firstname `
		-Surname $Lastname `
		-Description $jobtitle `
		-OfficePhone $phone
        	-Office $company `
		-Enabled $True `
		-DisplayName "$Firstname $Lastname " `
		-Path $OU `
		-EmailAddress $email `
		-Title $jobtitle `
		-Department $department `
		-AccountPassword (convertto-securestring $Password -AsPlainText -Force) -ChangePasswordAtLogon $True
#Office and company are the same attribute in AD.
	
		}


	Add-ADGroupMember -Identity ACL_office -Members $Username

#Sets proxy address in same format
	Set-ADUser -Identity $Username -Add @{Proxyaddresses=($proxyAddresses -split "\s+|\n")}
	
	Write-Host "$Username created"
	$counter++
	Start-Sleep -Seconds .5

}

Write-Host "$counter User(s) have been created."
Write-Host "Press ENTER to end session" 
$end = Read-Host	`