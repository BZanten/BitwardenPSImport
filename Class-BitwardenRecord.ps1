
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
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }
    [void] Init([PSCustomObject]$ExampleObject) {
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

class BWFolder : Helper {
    [string]$object;
    [string]$id;
    [string]$name;


    #
    # Constructor
    #
    BWFolder(  ) {
        $this.object = 'folder';
    }
}

class BWItem : Helper {
  [string[]]$passwordHistory;
    [string]$revisionDate;
    [string]$creationDate;
    [string]$object;
    [string]$id;
    [string]$folderId;
       [int]$type;
       [int]$reprompt;
    [string]$name;
    [string]$notes;
      [bool]$favorite;
  [string[]]$fields;
  [string[]]$collectionIds;
  [string[]]$attachments;

    #
    # Constructors
    #
    BWItem( ) {
        $this.object = 'item';
    }

    BWItem([hashtable]$Properties) { $this.Init($Properties) }

    BWItem([PSCustomObject]$ExampleObject) { $this.Init($ExampleObject) }

    BWItem(   [string[]]$passwordHistory,
                [string]$revisionDate,
                [string]$creationDate,
                [string]$id,
                [string]$folderId,
                [int]$type,
                [int]$reprompt,
                [string]$name,
                [string]$notes,
                [bool]$favorite,
            [string[]]$fields,
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
}

# ---------------------------------- Intermediate objects -----------------

class BWLoginObject : Helper {
  [string[]]$uris;
  [string[]]$fido2Credentials;
    [string]$username;
    [string]$password;
    [string]$totp;
    [string]$passwordRevisionDate;

    # Constructors
    BWLoginObject () { }
    BWLoginObject([hashtable]$Properties) { $this.Init($Properties) }
    BWLoginObject([PSCustomObject]$ExampleObject) { $this.Init($ExampleObject) }
}

class BWCardObject : Helper {
    [string]$cardholderName;
    [string]$brand;
    [string]$number;
    [string]$expMonth;
    [string]$expYear;
    [string]$code;

    # Constructors
    BWCardObject () { }
    BWCardObject([hashtable]$Properties) { $this.Init($Properties) }
    BWCardObject([PSCustomObject]$ExampleObject) { $this.Init($ExampleObject) }
}

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
    BWIdentityObject([hashtable]$Properties) { $this.Init($Properties) }
    BWIdentityObject([PSCustomObject]$ExampleObject) { $this.Init($ExampleObject) }

}

# ---------------------------------- BitWarden objects -----------------

class BWLogin : BWItem {
    [BWLoginObject]$login;

    # Constructor
    BWLogin () {
        $this.type = 1
    }

    BWLogin([hashtable]$Properties) { $this.Init($Properties) }

    BWLogin([PSCustomObject]$ExampleObject) { $this.Init($ExampleObject) }
}

class BWNote : BWItem {
#   [System.Management.Automation.PSCustomObject]$secureNote;
    [string]$secureNote;

    # Constructor
    BWNote () {
        $this.type = 2
    }

    BWNote([hashtable]$Properties) { $this.Init($Properties) }

    BWNote([PSCustomObject]$ExampleObject) { $this.Init($ExampleObject) }

    # ToString()  Method
    [string]ToString() {
        return $this.Name
    }
}

class BWCard : BWItem {
    [BWCardObject]$card;

    # Constructor
    BWCard () {
        this.type = 3
    }

    BWCard([hashtable]$Properties) { $this.Init($Properties) }

    BWCard([PSCustomObject]$ExampleObject) { $this.Init($ExampleObject) }

    # ToString()  Method
    [string]ToString() {
        return $this.Name
    }
}

class BWIdentity : BWItem {
    [BWIdentityObject]$card;

    # Constructor
    BWIdentity () {
        this.type = 4
    }

    BWIdentity([hashtable]$Properties) { $this.Init($Properties) }

    BWIdentity([PSCustomObject]$ExampleObject) { $this.Init($ExampleObject) }

    # ToString()  Method
    [string]ToString() {
        return $this.Name
    }
}

class BWSSHKey : BWItem {
    [BWIdentityObject]$card;

    # Constructor
    BWSSHKey () {
        this.type = 5
    }

    BWSSHKey([hashtable]$Properties) { $this.Init($Properties) }

    BWSSHKey([PSCustomObject]$ExampleObject) { $this.Init($ExampleObject) }

    # ToString()  Method
    [string]ToString() {
        return $this.Name
    }
}
class BWSoftwareLicense : BWItem {

    #
    # Constructor
    #
    BWProductKey(  ) {
        $this.Favorite = $False;
    }

    # ToString()  Method
    [string]ToString() {
        return $this.Name
    }
}

<#
class LPSoftwareLicense : LastPassRecord {

    [string]$NoteType
    [string]$LicenseKey
    [string]$Licensee
    [string]$Version
    [string]$Publisher
    [string]$SupportEmail
    [string]$Website
    [string]$Price
    [datetime]$PurchaseDate
    [string]$OrderNumber
    [string]$NumberOfLicenses
    [string]$OrderTotal
    [string]$Notes

    hidden    [string]$_Extra = $($this | Add-Member -MemberType ScriptProperty -Force -Name 'Extra' `
        -Value {
            # get
            $this.CalculateExtra()
            $this._Extra
        }`
        -SecondValue {
            # set
            param ( $arg )
            $this._Extra = $arg
        }
    )

    # Constructor:
    LPSoftwareLicense(  ) : base() {
        $this.url = 'http://sn'
        $this.NoteType='Software License'
        $this.PurchaseDate = '1 January 2000'
    }

    #
    # Method to recalculate Extra field
    #
    [void]CalculateExtra(){
        $this._Extra="NoteType:$($this.NoteType)
License Key:$($this.LicenseKey)
Licensee:$($this.Licensee)
Version:$($this.Version)
Publisher:$($this.Publisher)
Support Email:$($this.SupportEmail)
Website:$($this.Website)
Price:$($this.Price)
Purchase Date:$(($this.PurchaseDate).ToString("MMMM,dd,yyyy",$this.Culture))
Order Number:$($this.OrderNumber)
Number of Licenses:$($this.NumberOfLicenses)
Order Total:$($this.OrderTotal)
Notes:$($this.Notes)"
    }
}
#>
