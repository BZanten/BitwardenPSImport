
. .\Class-BitwardenRecord.ps1
. .\Functions\Initialize-PSBitwarden.ps1

# $VerbosePreference="Continue"
# $VerbosePreference="SilentlyContinue"

Initialize-PSBitwarden -Credential (Get-Credential Ben@van.Zanten.name)
$AllItems = bw list items | ConvertFrom-Json
$AllItems | Sort-Object -Property type,name | Select-Object -Property id,type,name,organizationId
$AllItems[100..260] | Where-Object { $_.type -eq 1 } | ForEach-Object { [bwlogin]$_ } | Select-Object -Property id,type,name

$AllItems | Where-Object { $_.type -eq 1 } | ForEach-Object {    [bwlogin]$_ } | Select-Object -Property id,type,name
$AllItems | Where-Object { $_.type -eq 2 } | ForEach-Object {     [bwnote]$_ } | Select-Object -Property id,type,name
$AllItems | Where-Object { $_.type -eq 3 } | ForEach-Object {     [bwcard]$_ } | Select-Object -Property id,type,name
$AllItems | Where-Object { $_.type -eq 4 } | ForEach-Object { [bwidentity]$_ } | Select-Object -Property id,type,name
$AllItems | Where-Object { $_.type -eq 5 } | ForEach-Object {   [bwsshkey]$_ } | Select-Object -Property id,type,name

$Login= New-Object -TypeName BWLoginObject
$Rec1 = New-Object -TypeName BWLogin
$Rec1
$Rec1.name="My BitWarden Login record"
$Login.userName="BZanten"
$Login.password="MyP@ssWr0d"
$Rec1.login = $Login
$Rec1
$Rec1.login

bw sync

$MyLogin = $AllItems | Where-Object { $_.type -eq 1 -and $_.Name -eq 'Login-test' } | ForEach-Object {    [bwlogin]$_ } | Select-Object -Property id,type,name
$MyLogin = [bwlogin]((bw list items --search Login-test | ConvertFrom-Json)[0])
$MyLogin
$MyLogin.login
$MyLogin.passwordHistory
$MyLogin.login.username='Bennie-4'
$MyLogin.login.password=( bw generate -lusn --length 18)
$MyLogin.Save()

$MyLogin2 = [BWLogin]((bw get item c47ad172-688f-4c1c-bfd8-b19a007d10b0) | ConvertFrom-Json )
$MyLogin2
$MyLogin2.login
$MyLogin2.login.uris


$MyNote = 'cc23e955-a81b-434f-b926-b18d012e252c'
$MyNote = $AllItems | Where-Object { $_.type -eq 2 -and $_.Name -eq 'Note-test' } | ForEach-Object {    [BWNote]$_ } | Select-Object -Property id,type,name
$MyNote = [BWNote]((bw list items --search Note-test | ConvertFrom-Json)[0])
$MyNote

$MyLicense = [BWSoftwareLicense]::New()
$MyLicense = [BWNote](bw get item 052325a1-2537-4b03-9e98-b18d012e252c | ConvertFrom-Json)
$MyLicense.notes -match 'ItemType' -or $MyLicense.notes -match 'NoteType'
$MyLicense.fields.ItemType

# empty license
$MyLicense2 = [BWNote](bw get item b86c753c-20ac-41cf-aa8f-b1c800837bca | ConvertFrom-Json)
$MyLicense2.notes -match 'ItemType' -or $MyLicense2.notes -match 'NoteType'
$MyLicense2.fields
$MyLicense2.fields.GetType()


# filled license
$MyLicense3String = (bw get item 4f83277e-ca2b-489f-940d-b2910187ed98)
$MyLicense3Object = $MyLicense3String | ConvertFrom-Json
$MyLicense3 = [BWNote]$MyLicense3Object
$MyLicense3.notes -match 'ItemType' -or $MyLicense3.notes -match 'NoteType'
$MyLicense3.fields
$MyLicense3.fields[0]
$MyLicense3.fields.GetType()
$MyLicense3.fields[0].GetType()
$MyLicense3.fields[0] | Get-Member
if ($MyLicense3.fields | Where-Object { $_.name -in ('ItemType','NoteType') -and $_.Value -match ('^Software\s{0,1}License$')}) { $MyLicense3 = [BWSoftwareLicense]$MyLicense3Object }

$MyLicense3.fields
($MyLicense3.fields | Where-Object { $_.name -in ('ItemType','NoteType')} ).value

# Query: show all items that have 'Fields' set
$AllItems | Where-Object { (!([string]::IsNullOrEmpty($_.fields))) } | Sort-Object -Property type,name | Select-Object -Property id,type,name

# All softwarelicenses with the correct field set
$AllItems | Where-Object { $_.type -eq 2 } | ForEach-Object { [bwnote]$_ } | Where-Object { $_.fields | Where-Object { $_.name -eq 'ItemType' -and $_.value -match ('^Software\s{0,1}License$') }} | Select-Object -Property id,type,name,fields

# All Softwarelicenses still information in 'Notes' field.
$AllItems | Where-Object { $_.type -eq 2 } | ForEach-Object { [bwnote]$_ } | Where-Object { $_.notes -match ('Software\s{0,1}License')} | Sort-Object -Property name,id | Select-Object -Property id,type,name


$MyLicenseString = (bw get item 588e7787-21e6-4b50-9c72-b18d012e252c)
$MyLicenseObject = $MyLicenseString | ConvertFrom-Json
$MyLicense = [BWNote]$MyLicenseObject
$MyLicense.notes -match 'ItemType' -or $MyLicense.notes -match 'NoteType'
$MyLicense.fields
if ($MyLicense.fields | Where-Object { $_.name -in ('ItemType','NoteType') -and $_.Value -match ('^Software\s{0,1}License$')}) { $MyLicense = [BWSoftwareLicense]$MyLicenseObject }
elseif ($MyLicense.notes -match ('Note\s*Type\s*:\s*Software\s{0,1}License')) {

    $MyLicense = [BWSoftwareLicense]$MyLicenseObject

<#
    ForEach ($Line in ($MyLicense.notes -split '\n')) {
        if ($line -match '^(.*?)\s*:\s*(.*)$') {
            switch ($Matches[1]) {
                { ('ItemType','NoteType') -contains $_ } {
                                        $MyLicense.ItemType = $Matches[2] ;
                                        # $MyLicense.notes = $MyLicense.notes -replace "$line\n",''
                                     }
                'License Key'        {
                                        $MyLicense.LicenseKey = $Matches[2] ;
                                        # $MyLicense.notes = $MyLicense.notes -replace "$line\n",''
                                     }
                'Language'           {
                                        $MyLicense.Language = $Matches[2] ;
                                        # $MyLicense.notes = $MyLicense.notes -replace "$line\n",''
                                     }
                'Licensee'           {
                                        $MyLicense.Licensee = $Matches[2] ;
                                        # $MyLicense.notes = $MyLicense.notes -replace "$line\n",''
                                     }
                'Version'            {
                                        $MyLicense.Version = $Matches[2] ;
                                        # $MyLicense.notes = $MyLicense.notes -replace "$line\n",''
                                     }
                'Publisher'          {
                                        $MyLicense.Publisher = $Matches[2] ;
                                        # $MyLicense.notes = $MyLicense.notes -replace "$line\n",''
                                     }
                'Support Email'      {
                                        $MyLicense.SupportEmail = $Matches[2] ;
                                        # $MyLicense.notes = $MyLicense.notes -replace "$line\n",''
                                     }
                'Website'            {
                                        $MyLicense.Website = $Matches[2] ;
                                        # $MyLicense.notes = $MyLicense.notes -replace "$line\n",''
                                     }
                'Price'              {
                                        $MyLicense.Price = $Matches[2] ;
                                        # $MyLicense.notes = $MyLicense.notes -replace "$line\n",''
                                     }
                'Purchase Date'      {
                                        $MyLicense.PurchaseDate = $Matches[2] ;
                                        # $MyLicense.notes = $MyLicense.notes -replace "$line\n",''
                                     }
                'Order Number'       {
                                        $MyLicense.OrderNumber = $Matches[2] ;
                                        # $MyLicense.notes = $MyLicense.notes -replace "$line\n",''
                                     }
                'Number of Licenses' {
                                        $MyLicense.NumberOfLicenses = $Matches[2] ;
                                        # $MyLicense.notes = $MyLicense.notes -replace "$line\n",''
                                     }
                'Order Total'        {
                                        $MyLicense.OrderTotal = $Matches[2] ;
                                        # $MyLicense.notes = $MyLicense.notes -replace "$line\n",''
                                     }
                'Licensee'           {
                                        $MyLicense.Licensee = $Matches[2] ;
                                        # $MyLicense.notes = $MyLicense.notes -replace "$line\n",''
                                     }
                 default             {"Onbekend: $line"}
            }
        }
    }
#>
    }
$MyLicense.ProductName = "MS Visio Pro 2019"
$MyLicense.LicenseType = "Retail"
$MyLicense.name = "Visio Pro 2019-2"
$MyLicense.name = "Visio Pro 2019-2 7BTNR"
$MyLicense.InstalledWhere='Babetje (HP Folio Anne-Marie)'

$MyLicense.Save()

$MyLicense.name
$MyLicense | Select-Object -Property name,object,id,type | ConvertTo-Json -Compress | bw encode | bw edit item $MyLicense.id | ConvertFrom-Json

# Werkt:
$MyLicenseString | bw encode | bw edit item $MyLicense.id | ConvertFrom-Json
bw sync

$MyLicenseString
$MyLicenseString | ConvertFrom-Json | gm
$ItemFields=@('passwordHistory','revisionDate','creationDate','object','id','folderId','type','reprompt','name','notes','favorite','fields','secureNote','collectionIds','attachments')
$ItemFields=@('passwordHistory','revisionDate','creationDate','object','id','folderId','type','reprompt','name','notes','favorite','fields',            ,'collectionIds','attachments')
$myLicenseString -eq ($MyLicense | Select-Object -Property $ItemFields | ConvertTo-Json -Compress)

$MyLicense.fields | ? { $_.name -eq 'LicenseKey'} | % { $_.Value = '7BTNR-3PKBD-GTW38-FBY6M-F9D4P'}


($MyLicense | Select-Object -Property $ItemFields | ConvertTo-Json -Compress) | bw encode | bw edit item $MyLicense.id | ConvertFrom-Json

$MyLicenseString
$MyLicenseString.secureNote

bw get template item | ConvertFrom-Json
bw get template item.login | ConvertFrom-Json
bw get template item.field | ConvertFrom-Json
bw get template item.login.uri | ConvertFrom-Json
bw get template item.login.fido2Credential | ConvertFrom-Json
bw get template item.card | ConvertFrom-Json
bw get template item.identity | ConvertFrom-Json
bw get template item.securenote | ConvertFrom-Json

item.card item.identity item.securenote

# New software:
$Software = New-Object -TypeName BWSoftwareLicense -Argumentlist @{name='Babbel';ProductName='All Languages';Publisher='Babbel GmbH'}
$Software
$Software.Save()
#
$AllItems | Where-Object { $_.type -eq 1 } | ForEach-Object {    [bwlogin]$_ } | Sort-Object -Property name | Select-Object -Property id,name,@{n='Uris';e={$_.Login.Uris}}

$AllItems | Where-Object { $_.type -eq 1 } | Select-Object -ExpandProperty login | Select-Object -ExpandProperty uris

$Visio2 =  [BWSoftwareLicense]((bw get item 706f61d3-e718-41d1-b31f-b18d012e252c) | ConvertFrom-Json)
$Visio2.ProductName = "MS Visio Pro 2019"
$Visio2.InstalledWhere='VAL7071'
$Visio2.notes=''
$Visio2
$Visio2.Save()

$Softwares = $AllItems | Where-Object { $_.type -eq 2 -and $_.name -match 'dbforce' } | ForEach-Object {     [bwnote]$_ } | Select-Object -Property id,type,name
ForEach ($Software in $Softwares) { }
$Softwares
$Software = $Softwares[0]
$AllItems | Where-Object { $_.type -eq 2 } | ForEach-Object {     [bwnote]$_ } | Where-Object { $_.notes -match 'software\s*license'} | Select-Object -Property id,type,name
$Software = $AllItems | Where-Object { $_.type -eq 2 } | ForEach-Object {     [bwnote]$_ } | Select-Object -Property id,type,name | Out-GridView -Title "select a software" -OutputMode Single
$Software = $AllItems | Where-Object { $_.type -eq 2 } | ForEach-Object { [bwnote]$_ } | Where-Object { $_.notes -match ('Software\s{0,1}License')} | Sort-Object -Property name,id | Select-Object -Property id,type,name | Out-GridView -Title "select a software" -OutputMode Single

$JSon = '{"passwordHistory":[],"revisionDate":"","creationDate":"","object":"item","id":"","folderId":"","type":2,"reprompt":0,"name":"Babbel","notes":"","favorite":false,"fields":[{"name":"ProductName","value":"All Languages","type":0},{"name":"Publisher","value":"Babbel GmbH","type":0}],"secureNote":{"type":0},"collectionIds":[],"attachments":[]}'
$JSon | bw encode | bw create item

$SoftwareObj = [BWSoftwareLicense]((bw get item $Software.id) | ConvertFrom-Json)
$SoftwareObj.ProductName = 'Office'
$SoftwareObj.Version='1997'

$SoftwareObj.Publisher = 'Microsoft'
$SoftwareObj.LicenseType='x'
$SoftwareObj.Name = ([string]::Format("{0} {1} {2} - {3}",$SoftwareObj.Publisher,$SoftwareObj.ProductName,$SoftwareObj.Version,(($SoftwareObj.LicenseKey -split '-')[0]))).Trim()
$SoftwareObj.InstalledWhere='Manon voor Williams laptop'
$SoftwareObj.InstalledWhen='Jan 2019'
# $SoftwareObj.Name = "SUMO Lifetime license - 7008"
# $SoftwareObj.LicenseKey = 'x'
$SoftwareObj.Language='EN-US'
$SoftwareObj.Licensee='B.A.M. van Zanten'
$SoftwareObj.NumberOfLicenses=1
$SoftwareObj.OrderNumber=0
$SoftwareObj.OrderTotal=1
$SoftwareObj.Price=0
$SoftwareObj.PurchaseDate='x'
$SoftwareObj.SupportEmail='@'
$SoftwareObj.Website='http'
#
$SoftwareObj
#
$SoftwareObj.Save()
$SoftwareObj | Select-Object -ExpandProperty fields

# -----------------------------------------------------------------------------------

$VerbosePreference="SilentlyContinue"
. .\Class-BitwardenRecord.ps1
bw sync
$AllItems = bw list items | ConvertFrom-Json
$VerbosePreference="Continue"

$Softwares = $AllItems | Where-Object { $_.type -eq 2 } | ForEach-Object { [bwnote]$_ } | Where-Object { $_.notes -match ('Software\s{0,1}License')} | Sort-Object -Property name,id | Select-Object -Property id,type,name | Out-GridView -Title "select a software" -OutputMode Multiple
$Software = $Softwares[0]
ForEach ($Software in $Softwares) {
   $SoftwareObj = [BWSoftwareLicense]((bw get item $Software.id) | ConvertFrom-Json)
   $SoftwareObj.ProductName = 'Windows Server Remote Desktop Services device connections (50)'
   $SoftwareObj.Version='2019'
   $SoftwareObj.Edition='RDS'
   $SoftwareObj.Publisher = 'Microsoft'
   $SoftwareObj.Name = ([string]::Format("{0} {1} {2} {3} - {4}",$SoftwareObj.Publisher,$SoftwareObj.ProductName,$SoftwareObj.Version,$SoftwareObj.Edition,(($SoftwareObj.LicenseKey -split '-')[0]))).Trim()
   $SoftwareObj.Name
   $SoftwareObj.LicenseType='Retail'
   $SoftwareObj.notes
   $SoftwareObj.notes = ($SoftwareObj.notes -replace 'notes\s*:','').Trim()
   $SoftwareObj.notes
#   $SoftwareObj.Notes=''
   #
   $SoftwareObj
   #
   $SoftwareObj.Save()
}

# -------------------------------------------------------------------------------------------------------------------
#  Read licenses from MSDN and see if they are imported in BitWarden
# -------------------------------------------------------------------------------------------------------------------
bw sync
$AllItems = bw list items | ConvertFrom-Json
$AllSoftware = $AllItems | Where-Object { $_.type -eq 2 } | Where-Object { $_.fields | Where-Object { $_.name -eq 'ItemType' -and $_.value -match ('^Software\s{0,1}License$') }} | ForEach-Object { [BWSoftwareLicense]$_ }

<#
$Software = $AllSoftware[100]
$Software.GetType()
$Software
$Software.LicenseKey
#>

$SoftwareHash = $AllSoftware | Select-Object -Property LicenseKey,Name,Version,LicenseType | Group-Object -Property LicenseKey -AsHashTable
# $SoftwareHash.Keys | sort


[xml]$KeysExport = Get-Content .\KeysExport.xml
$KeysExport.root.YourSubscription.Subscription.SubscriptionGuid
$KeysExport.root.YourKey.Product_Key.count

# ($KeysExport.root.YourKey.Product_Key) | Select-Object -Property Name -ExpandProperty Key -ErrorAction SilentlyContinue


<#
$ExportKey = ($KeysExport.root.YourKey.Product_Key)[-3]
ForEach ($ExportKey in ($KeysExport.root.YourKey.Product_Key)) {
   $ExportKey | Select-Object -ExpandProperty Key | Where-Object { $_.'#text' -in $AllSoftware.LicenseKey }
}

$SoftwareHash['T4X62-TND8X-HB6F7-G9F6D-M7YVQ'] # 'Win Server 2025 Standard'
$SoftwareHash['FVC7J-CRVWM-378YB-C79J8-JBGHG'] # 'Win XP media Center Edition'
#>

($KeysExport.root.YourKey.Product_Key) | Measure-Object
($KeysExport.root.YourKey.Product_Key) | Where-Object { $_.Name -eq 'Windows Server 2025 Standard'} | Select-Object -Property @{n='Naam';e={$_.Name}} -ExpandProperty Key | FT -AutoSize -Property Naam,Type,ClaimedDate,'#text'

$ExportKeyHash=@{}
$ExportNameHash = ($KeysExport.root.YourKey.Product_Key) | Group-Object -Property Name -AsHashTable
$ExportNameHash['Access 2003'].Key
$ExportNameHash['Windows Server 2025 Standard'].Key | Format-Table -AutoSize


$SWName = 'Windows Server 2025 Datacenter'
ForEach ($SWName in $ExportNameHash.Keys) {
    $ExportNameHash[$SWName].Key | ForEach-Object { if ($_.'#text' -match '^[A-Z,0-9]{5}(\-[A-Z,0-9]{5}){4}$') {  $ExportKeyHash[$_.'#text'] = [PSCustomObject]@{ Name = $SWName ; ID = $_.ID ; Type = $_.Type ; ClaimedDate = $_.ClaimedDate ; Key = $_.'#text' }} }
}

$ExportKeyHash.Keys
$ExportKeyHash.Values
$ExportKeyHash['NYG9F-XMJB7-4XK9M-YTFKJ-MTG9T']
$SoftwareHash['NYG9F-XMJB7-4XK9M-YTFKJ-MTG9T']
$ExportKeyHash.Keys | Where-Object { -not $SoftwareHash[$_]} | % { $ExportKeyHash[$_] } | Sort Name |  Format-Table -AutoSize
# $ProductKey = 'VKXMY-3XWC2-FCGGQ-2WD2G-P6WJT'
# $ProductKey = 'F3JM7-7QNWQ-KKFVP-PDDRT-4M6P7'
# $ProductKey = 'BXN8V-DC6WV-WV88X-KC7TF-BY69J'
# $ProductKey = '36D7J-FR6QG-JXPF6-H449P-2P6RR'

ForEach ($Productkey in (($ExportKeyHash.Keys | Where-Object { -not $SoftwareHash[$_]} | % { $ExportKeyHash[$_] } | Sort-Object -Property Name).Key)) {
   $Productkey

   $ExportKeyHash[$ProductKey]
   $SoftwareHash[$ProductKey]
   if ($ExportKeyHash[$ProductKey].Name -match '([\d\.]+)') { $Version = $Matches[0] } else { $Version = 'x' }

   $Name = ([string]::Format("{0} {1} {2} - {3}",'Microsoft',$ExportKeyHash[$ProductKey].Name,$ExportKeyHash[$ProductKey].Edition,(($ProductKey -split '-')[0]))).Trim()
   if ([string]::IsNullOrEmpty($ExportKeyHash[$ProductKey].ClaimedDate)) {$ClaimedDate='x'} else {$ClaimedDate=$ExportKeyHash[$ProductKey].ClaimedDate}
   (New-Object -TypeName BWSoftwareLicense -ArgumentList @{
      name        = $Name;
      ProductName = $ExportKeyHash[$ProductKey].Name;
      LicenseKey  = $ProductKey;
      Publisher   = 'Microsoft';
      PurchaseDate= $ClaimedDate;
      LicenseType = $ExportKeyHash[$ProductKey].Type;
      Licensee    = 'B.A.M. van Zanten';
      Version     = $Version
   } ).Save()
}
