
#
# https://xainey.github.io/2016/powershell-classes-and-concepts/
#

#
#  A Normal Bitwarden Record has 7 fields.
#   the Url property can have any value, that becomes the URL field
#   the Extra property can have any value, that becomes the Note field
#

# 1 Login
# 3 Card
# 4 Identity
# 2 Note
# 5 SSH key

<#
f97a7163-c677-4792-b2a1-b3bb01145d06    1 Login-test
b2b5d405-844f-4b2c-a559-b3bb011491e3    2 Note-test
c81edecd-7822-4409-99fc-b3bb01146e9c    3 Card-test
1b58c774-0aa6-4429-a1e6-b3bb011484cd    4 Identity-test
6eb2cbe4-7a6b-4497-82c9-b3bb0114a437    5 SSHKey-test
#>

class Helper {

    [HashTable] Splat([String[]] $Properties) {
        $splat = @{}

        foreach($prop in $Properties) {
            if($this.GetType().GetProperty($prop)) {
                $splat.Add($prop, $this.$prop)
            }
        }
        return $splat
    }

    [void] Init([hashtable]$Properties) {
        Write-Verbose "Initializing object $($this.GetType().ToString()) via Hashtable..."
        foreach ($Property in $Properties.Keys) {
            Write-Verbose "$Property = $($Properties.$Property)"
            $this.$Property = $Properties.$Property
        }
    }
    [void] Init([PSCustomObject]$ExampleObject) {
        Write-Verbose "Initializing object $($this.GetType().ToString()) via Example Object..."
        foreach ($Property in ($ExampleObject | Get-Member -MemberType NoteProperty)) {
            Write-Verbose "$($Property.name) = $($ExampleObject.($Property.name))"
            $this.($Property.name) = $ExampleObject.($Property.name)
        }
    }

    # ToString()  Method
    [string]ToString() {
        return $this.Name
    }
}

class BWField : Helper {
    [string]$name;
    [string]$value;
       [int]$type;

    # Constructor
    BWField() {}
    BWField([hashtable]$Properties)         { $this.Init($Properties) }
    BWField([PSCustomObject]$ExampleObject) { $this.Init($ExampleObject) }
}

class BWUri : Helper {
    [string]$match;
    [string]$uri;

    # Constructor
    BWUri() {}
    BWUri([hashtable]$Properties)         { $this.Init($Properties) }
    BWUri([PSCustomObject]$ExampleObject) { $this.Init($ExampleObject) }

    [string]ToString() {
        return $this.uri
    }
}

class BWFolder : Helper {
    [string]$object;
    [string]$id;
    [string]$name;

    # Constructor
    BWFolder(  ) {
        $this.object = 'folder';
    }

    BWFolder([hashtable]$Properties)         { $this.Init($Properties) }
    BWFolder([PSCustomObject]$ExampleObject) { $this.Init($ExampleObject) }
}

<#
PS C:\git\BZanten\BitwardenPSImport> bw get template item | ConvertFrom-Json
    passwordHistory : {}
    revisionDate    :
    creationDate    :
    deletedDate     :
    archivedDate    :
    organizationId  :
    collectionIds   :
    folderId        :
    type            : 1
    name            : Item name
    notes           : Some notes about this item.
    favorite        : False
    fields          : {}
    login           :
    secureNote      :
    card            :
    identity        :
    sshKey          :
    reprompt        : 0
#>
class BWItem : Helper {
    [string]$object="";
    [string]$id="";
  [BWPwHistoryObject[]]$passwordHistory=@();
    [string]$revisionDate="";
    [string]$creationDate="";
    [string]$deletedDate="";
    [string]$archivedDate="";
    [string]$organizationId="";
  [string[]]$collectionIds=@();
    [string]$folderId="";
       [int]$type=0;
    [string]$name="";
    [string]$notes="";
    [bool]$favorite=$false;
    [System.Collections.ArrayList]$fields=@();
       [int]$reprompt=0;
    [string]$key="";
  [string[]]$attachments=@();

  # System.Collections.ArrayList
  # Collections.Generic.List


    # Constructors
    BWItem( ) {
        $this.object = 'item';
    }

    BWItem([hashtable]$Properties)         { $this.Init($Properties) }
    BWItem([PSCustomObject]$ExampleObject) { $this.Init($ExampleObject) }

    BWItem(   [BWPwHistoryObject[]]$passwordHistory,
                [string]$revisionDate,
                [string]$creationDate,
                [string]$id,
                [string]$folderId,
                [int]$type,
                [int]$reprompt,
                [string]$name,
                [string]$notes,
                [bool]$favorite,
    [System.Collections.ArrayList]$fields,
            [string[]]$collectionIds,
            [string[]]$attachments
   ) {
        $this.object = 'item';
        $this.revisionDate=$revisionDate;
        $this.creationDate=$creationDate;
        $this.id=$id;
        $this.folderId=$folderId;
        $this.type=$type;
        $this.reprompt=$reprompt;
        $this.name=$name;
        $this.notes=$notes;
        $this.favorite=$favorite;
        $this.fields=$fields;
        $this.collectionIds=$collectionIds;
        $this.attachments=$attachments
    }

    [bool] Save() {
        try {

            $ItemFields = ( [BWItem]::New() | Get-Member -MemberType Property,NoteProperty | Select-Object -Property Name ).Name | Where-Object { $_ -notin ('key','organizationId') }
            $ItemFields = @('passwordHistory','revisionDate','creationDate','object','id','folderId','type','reprompt','name','notes','favorite','fields','secureNote','collectionIds','attachments')
            $JsonRaw = $this | Select-Object -Property $ItemFields | ConvertTo-Json -Compress
            $JsonEnc = $JsonRaw | bw encode
            Write-Verbose "JSON Raw: $JsonRaw"
            Write-Verbose "JSON Enc: $JsonEnc"
            if ( [string]::IsNullOrEmpty($this.id)) {
                Write-Verbose "Saving new item:"
                bw create item $JsonEnc | ConvertFrom-Json
            } else {
                Write-Verbose "Saving existing item: $($this.id)"
#               $JsonRaw | bw encode | bw edit item $this.id $this.object | ConvertFrom-Json
                bw edit item $this.id $JsonEnc | ConvertFrom-Json
            }
            return $true
        }
        catch {
            throw $_
            return $false
        }
    }
}

# ---------------------------------- Intermediate objects -----------------

<#
PS C:\git\BZanten\BitwardenPSImport> bw get template item.login | ConvertFrom-Json

    uris             : {}
    username         : jdoe
    password         : myp@ssword123
    totp             : JBSWY3DPEHPK3PXP
    fido2Credentials : {}
#>
class BWLoginObject : Helper {
    [BWUri[]]$uris;
     [string]$username;
     [string]$password;
     [string]$totp;
   [string[]]$fido2Credentials;
     [string]$passwordRevisionDate;

    # Constructors
    BWLoginObject () { }
    BWLoginObject([hashtable]$Properties)         { $this.Init($Properties) }
    BWLoginObject([PSCustomObject]$ExampleObject) { $this.Init($ExampleObject) }

    [string]ToString() {
        return $this.username
    }
}

<#
PS C:\git\BZanten\BitwardenPSImport> bw get template item.securenote | ConvertFrom-Json
    type
    ----
    0
#>
class BWNoteObject : Helper {
    [int]$type;

    # Constructors
    BWNoteObject( )                              {                               Write-Verbose "Initializing BWNoteObject type with $($this.type)" ; $this.type=0 ; Write-Verbose "Initializing bwnoteobject type with $($this.type)" }
    BWNoteObject([hashtable]$Properties)         { $this.Init($Properties)     ; Write-Verbose "Initializing type with $($this.type)" }
    BWNoteObject([PSCustomObject]$ExampleObject) { $this.Init($ExampleObject)  ; Write-Verbose "Initializing type with $($this.type)" }

    [string]ToString() {
        return $this.type
    }
}

<#
PS C:\git\BZanten\BitwardenPSImport> bw get template item.card | ConvertFrom-Json

    cardholderName : John Doe
    brand          : visa
    number         : 4242424242424242
    expMonth       : 04
    expYear        : 2023
    code           : 123
#>
class BWCardObject : Helper {
    [string]$cardholderName;
    [string]$brand;
    [string]$number;
    [string]$expMonth;
    [string]$expYear;
    [string]$code;

    # Constructors
    BWCardObject () { }
    BWCardObject([hashtable]$Properties)         { $this.Init($Properties) }
    BWCardObject([PSCustomObject]$ExampleObject) { $this.Init($ExampleObject) }

    [string]ToString() {
        return ([string]::Format("{0}\{1} - {2}/{3}",$this.brand,$this.cardholderName,$this.expMonth,$this.expYear))
    }
}

<#
PS C:\git\BZanten\BitwardenPSImport> bw get template item.identity | ConvertFrom-Json

    title          : Mr
    firstName      : John
    middleName     : William
    lastName       : Doe
    address1       : 123 Any St
    address2       : Apt #123
    address3       :
    city           : New York
    state          : NY
    postalCode     : 10001
    country        : US
    company        : Acme Inc.
    email          : john@company.com
    phone          : 5555551234
    ssn            : 000-123-4567
    username       : jdoe
    passportNumber : US-123456789
    licenseNumber  : D123-12-123-12333
#>
class BWIdentityObject : Helper {
    [string]$title;
    [string]$firstName;
    [string]$middleName;
    [string]$lastName;
    [string]$address1;
    [string]$address2;
    [string]$address3;
    [string]$city;
    [string]$state;
    [string]$postalCode;
    [string]$country;
    [string]$company;
    [string]$email;
    [string]$phone;
    [string]$ssn;
    [string]$username;
    [string]$passportNumber;
    [string]$licenseNumber;

    # Constructors
    BWIdentityObject () { }
    BWIdentityObject([hashtable]$Properties)         { $this.Init($Properties) }
    BWIdentityObject([PSCustomObject]$ExampleObject) { $this.Init($ExampleObject) }
}

class BWSshKeyObject : Helper {
    [string]$keyFingerprint;
    [string]$privateKey;
    [string]$publicKey;

    # Constructors
    BWSshKeyObject () { }
    BWSshKeyObject([hashtable]$Properties)         { $this.Init($Properties) }
    BWSshKeyObject([PSCustomObject]$ExampleObject) { $this.Init($ExampleObject) }
}

class BWPwHistoryObject : Helper {
    [string]$lastUsedDate;
    [string]$password;

    # Constructors
    BWPwHistoryObject () { }
    BWPwHistoryObject([hashtable]$Properties)         { $this.Init($Properties) }
    BWPwHistoryObject([PSCustomObject]$ExampleObject) { $this.Init($ExampleObject) }
}

# ---------------------------------- BitWarden objects -----------------

class BWLogin : BWItem {
    [BWLoginObject]$login;

    # Constructor
    BWLogin () {
        $this.type = 1
    }

    BWLogin([hashtable]$Properties)         { $this.Init($Properties) }
    BWLogin([PSCustomObject]$ExampleObject) { $this.Init($ExampleObject) }
}

class BWNote : BWItem {
#   [System.Management.Automation.PSCustomObject]$secureNote;
    [BWNoteObject]$secureNote=(New-Object -TypeName BWNoteObject -ArgumentList @{type=0});

    # Constructor
    BWNote () {
        $this.type = 2;
        Write-Verbose "1. BWNote type: $($this.type) secureNote-type: $($this.secureNote.type)"
#        $this.secureNote = New-Object -TypeName BWNoteObject -ArgumentList @{type=0}
        Write-Verbose "1. BWNote type: $($this.type) secureNote-type: $($this.secureNote.type)"
    }

    BWNote([hashtable]$Properties)         { $this.Init($Properties)    ; $this.type = 2 ; Write-Verbose "2. BWNote type: $($this.type) securenote: $($this.secureNote.type)"}
    BWNote([PSCustomObject]$ExampleObject) { $this.Init($ExampleObject) ; $this.type = 2 ; Write-Verbose "3. BWNote type: $($this.type) securenote: $($this.secureNote.type)"}

    # ToString()  Method
    [string]ToString() {
        return $this.Name
    }
}

class BWCard : BWItem {
    [BWCardObject]$card;

    # Constructor
    BWCard () {
        $this.type = 3
    }

    BWCard([hashtable]$Properties)         { $this.Init($Properties) }
    BWCard([PSCustomObject]$ExampleObject) { $this.Init($ExampleObject) }

    # ToString()  Method
    [string]ToString() {
        return $this.Name
    }
}

class BWIdentity : BWItem {
    [BWIdentityObject]$identity;

    # Constructor
    BWIdentity () {
        $this.type = 4
    }

    BWIdentity([hashtable]$Properties)         { $this.Init($Properties) }
    BWIdentity([PSCustomObject]$ExampleObject) { $this.Init($ExampleObject) }

    # ToString()  Method
    [string]ToString() {
        return $this.Name
    }
}

class BWSSHKey : BWItem {
    [BWSshKeyObject]$sshKey;

    # Constructor
    BWSSHKey () {
        $this.type = 5
    }

    BWSSHKey([hashtable]$Properties)         { $this.Init($Properties) }
    BWSSHKey([PSCustomObject]$ExampleObject) { $this.Init($ExampleObject) }

    # ToString()  Method
    [string]ToString() {
        return $this.Name
    }
}
class BWSoftwareLicense : BWNote {

<#
    [string]$ItemType;
    [string]$ProductName;
    [string]$Language;
    [string]$LicenseKey;
    [string]$Licensee;
    [string]$Version;
    [string]$Edition;
    [string]$Publisher;
    [string]$SupportEmail;
    [string]$Website;
    [string]$Price;
    [string]$PurchaseDate;
    [string]$OrderNumber;
    [string]$NumberOfLicenses;
    [string]$OrderTotal;
    [string]$LicenseType;
    [string]$InstalledWhen;
    [string]$InstalledWhere;

#>
    [string]$ItemType="Software License";
    [string]$ProductName="x";
    [string]$Language="x";
    [string]$LicenseKey="x";
    [string]$Licensee="x";
    [string]$Version="x";
    [string]$Edition="x";
    [string]$Publisher="x";
    [string]$SupportEmail="x";
    [string]$Website="x";
    [string]$Price="x";
    [string]$PurchaseDate="x";
    [string]$OrderNumber="x";
    [string]$NumberOfLicenses="x";
    [string]$OrderTotal="x";
    [string]$LicenseType="x";
    [string]$InstalledWhen="x";
    [string]$InstalledWhere="x";

    [void] Init([hashtable]$Properties) {
        Write-Verbose "Initializing object $($this.GetType().ToString()) via Hashtable..."
        foreach ($Property in $Properties.Keys) {
            Write-Verbose "$Property = $($Properties.$Property)"
            switch ($Property) {
                'notes' {
                            Write-Verbose "Initializing object $($this.GetType().ToString()) via Hashtable 1"
                }
                'fields' {
                            Write-Verbose "Initializing object $($this.GetType().ToString()) via Hashtable 1"
                }
                default {
                            Write-Verbose "Initializing object $($this.GetType().ToString()) via Hashtable 2."
                            $this.$Property = $Properties.$Property
                }
            }
        }
    }

    [void] Init([PSCustomObject]$ExampleObject) {
        Write-Verbose "Initializing object $($this.GetType().ToString()) via example Object..."
        foreach ($Property in ($ExampleObject | Get-Member -MemberType NoteProperty)) {
            Write-Verbose ".  $($Property.name) = $($ExampleObject.($Property.name))"
            switch ($Property.name) {

                'notes' {
                            Write-Verbose ".  Initializing property $($Property.name) via Example 1-ItemType"
                            $this.($Property.name) = $ExampleObject.($Property.name)

                            ForEach ($Line in ($this.notes -split '\n')) {
                                # Use RegEx to split the line on the first : char, where everything before the first : is the fieldname, and everything after is the value
                                if ($line -match '^(.*?)\s*:\s*(.*)$') {
                                    $PropertyName = $Null
                                    switch ($Matches[1]) {
                                        { ('ItemType','NoteType') -contains $_ } {
                                                                $PropertyName = 'ItemType'
                                                                # $this.ItemType = $Matches[2] ;
                                                                # $this.notes = $this.notes -replace "$line\n",''
                                                            }
                                        { ('License Key','LicenseKey') -contains $_ }        {
                                                                $PropertyName = 'Licensekey'
                                                                # $this.LicenseKey = $Matches[2] ;
                                                                # $this.notes = $this.notes -replace "$line\n",''
                                                            }
                                        {('Support Email','SupportEmail') -contains $_ }      {
                                                                $PropertyName = 'SupportEmail'
                                                                # $this.SupportEmail = $Matches[2] ;
                                                                # $this.notes = $this.notes -replace "$line\n",''
                                                            }
                                        {('Purchase Date','PurchaseDate' -contains $_ )}     {
                                                                $PropertyName = 'PurchaseDate'
                                                                # $this.PurchaseDate = $Matches[2] ;
                                                                # $this.notes = $this.notes -replace "$line\n",''
                                                            }
                                        {('Order Number','OrderNumber' -contains $_ )}      {
                                                                $PropertyName = 'OrderNumber'
                                                                ## $this.OrderNumber = $Matches[2] ;
                                                                # $this.notes = $this.notes -replace "$line\n",''
                                                            }
                                        {('Number of Licenses','NumberOfLicenses' -contains $_ )} {
                                                                $PropertyName = 'NumberOfLicenses'
                                                                # $this.NumberOfLicenses = $Matches[2] ;
                                                                # $this.notes = $this.notes -replace "$line\n",''
                                                            }
                                        {('Order Total','OrderTotal' -contains $_ )}       {
                                                                $PropertyName = 'OrderTotal'
                                                                # $this.OrderTotal = $Matches[2] ;
                                                                # $this.notes = $this.notes -replace "$line\n",''
                                                            }
                                        {('Language','Licensee','Version','Publisher','Website','Price','Licensee') -contains $_ } {
                                                                $PropertyName = $_
                                                                # $this.notes = $this.notes -replace "$line\n",''
                                                            }
                                        default             {
                                                                $PropertyName = $null
                                                                "Onbekend: $line"
                                                            }
                                    }
                                    if ($PropertyName) {
                                        if ([string]::IsNullOrEmpty($this.($PropertyName)) -or ( $this.($PropertyName) -eq 'x' -and -not [string]::IsNullOrEmpty($Matches[2]) )) {
                                            Write-Verbose ".    (Over)writing field '$PropertyName' value '$($this.($PropertyName))' with another value: '$($Matches[2])'"
                                            $this.($PropertyName) = $Matches[2] ;
                                            $this.notes = $this.notes -replace "$line\n",''
                                        } else {
                                            Write-Verbose ".    NOT Overwriting field '$PropertyName' value '$($this.($PropertyName))' with another value: '$($Matches[2])'"
                                            Write-Verbose "Replacing line: $line"
                                            $this.notes = $this.notes -replace "$line\n",''
                                        }
                                    }
                                }
                            }
                            $this.notes = $this.notes -replace "$line\n",''


                }

                'fields' {
                            Write-Verbose "Initializing property $($Property.name) with value $($ExampleObject.($Property.name))"
                            $this.($Property.name) = $ExampleObject.($Property.name)
                            foreach($field in $this.fields) {
                                Write-Verbose ".  Processing field: $($field.name) ..."
                                switch ($field.name) {
                                    {('Product','ProductName') -contains $_ } {
                                                    Write-Verbose ".    Field ProductName found"
                                                    $this.ProductName = $field.value
                                    }
                                    {('ItemType','Language','LicenseKey','Licensee','Version','Edition','Publisher','SupportEmail','Website','Price','PurchaseDate','OrderNumber','NumberOfLicenses','OrderTotal','LicenseType','InstalledWhen','InstalledWhere' -contains $_ )} {
                                                    Write-Verbose ".    Field '$_' found -value $($field.value)"
                                                    $this.($_) = $field.value
                                    }
                                    default { Write-Verbose ".    unknown field: $($field.name) -value  $($field.value)"}
                                }
                            }
                }
                default {
                            Write-Verbose "Initializing property $($Property.name) value $($ExampleObject.($Property.name))"
                            $this.($Property.name) = $ExampleObject.($Property.name)
                }
            }
        }
    }

    #
    # Constructor
    #
    BWSoftwareLicense(  ) {
        $this.Favorite = $False;
    }
    BWSoftwareLicense([hashtable]$Properties)         { $this.Init($Properties) }
    BWSoftwareLicense([PSCustomObject]$ExampleObject) { $this.Init($ExampleObject) }

    # ToString()  Method
    [string]ToString() {
        return $this.Name
    }

    # override the base Save...  make sure the additional properties are saved in fields.
    [bool] Save() {
        # if ($MyLicense3.fields | Where-Object { $_.name -eq 'ItemType' -and $_.Value -match ('^Software\s{0,1}License$')}) { $MyLicense3 = [BWSoftwareLicense]$MyLicense3Object }
        'ItemType','ProductName','Language','Licensee','Version','Edition','Publisher','SupportEmail','Website','Price','PurchaseDate','OrderNumber','NumberOfLicenses','OrderTotal','LicenseType','InstalledWhen','InstalledWhere' | ForEach-Object {
            $FieldName = $_
            Write-Verbose "Processing $FieldName ..."
            if (!([string]::IsNullOrEmpty($this.($FieldName)))) {
                if ($this.fields | Where-Object { $_.Name -eq $FieldName }) {
                    Write-Verbose "Updating existing field $FieldName"
                    ($this.fields | Where-Object { $_.name -eq $FieldName } ).value = $this.($FieldName)
                } else {
                    Write-Verbose "Creating new field $FieldName"
                    $newField = New-Object -TypeName 'BWField' -ArgumentList @{type=0 ; name=$FieldName ; value=$this.($FieldName)}
                    $this.fields.Add($newField )
                }
            }
        }

        'LicenseKey' | ForEach-Object {
            $FieldName = $_
            Write-Verbose "Processing $FieldName ..."
            if (!([string]::IsNullOrEmpty($this.($FieldName)))) {
                if ($this.fields | Where-Object { $_.Name -eq $FieldName }) {
                    Write-Verbose "Updating existing field $FieldName"
                    ($this.fields | Where-Object { $_.name -eq $FieldName } ).value = $this.($FieldName)
                } else {
                    Write-Verbose "Creating new field $FieldName"
                    $newField = New-Object -TypeName 'BWField' -ArgumentList @{type=1 ; name=$FieldName ; value=$this.($FieldName)}
                    $this.fields.Add($newField )
                }
            }
        }

        Write-Verbose "Calling base - Save method..."
        return ([BWNote]$this).Save()
    }
}

