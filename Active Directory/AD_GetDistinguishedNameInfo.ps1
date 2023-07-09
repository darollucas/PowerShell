<#
.SYNOPSIS
A script to get the Distinguished Name of an Active Directory user or computer based on the username or computer name.

.DESCRIPTION
This script retrieves the Distinguished Name (DN) of a user or a computer in Active Directory (AD). The Distinguished Name is a unique identifier that specifies the user's or computer's exact position in the AD tree hierarchy.

The script prompts the user for input to decide whether they want to search for a user or a computer and for the respective name.

This script requires the Active Directory PowerShell module to run.

.EXAMPLE
.\Get-DistinguishedName.ps1 
Run the script without parameters, it will prompt for the object type (User or Computer) and the name.
#>

# Function to get the Distinguished Name 
Function Get-DistinguishedName ($strName, $objectClass) 
{  
   # Create a new DirectorySearcher object to search the Active Directory
   $searcher = New-Object System.DirectoryServices.DirectorySearcher([ADSI]'')

   # Append a '$' to the name if searching for a computer
   if ($objectClass -eq "Computer") {
      $strName += '$'
   }

   # Set the search filter to find the user or computer with the specified name
   $searcher.Filter = "(&(objectClass=$objectClass)(samAccountName=$strName))" 

   try {
      # Execute the search
      $result = $searcher.FindOne()
   }
   catch {
      Write-Error "An error occurred while searching for the $objectClass. Please ensure the name is correct and try again."
      return $null
   }

   if ($null -eq $result) {
      Write-Error "No $objectClass found with the name '$strName'."
      return $null
   }

   # Return the Distinguished Name of the found object
   Return $result.GetDirectoryEntry().DistinguishedName 
} 

# Prompt the user for the object type (User or Computer)
$objectClass = Read-Host "Please enter the type of object you want to find (User or Computer)"

# Validate the input
if ($objectClass -ne "User" -and $objectClass -ne "Computer") {
   Write-Error "Invalid object type. Please enter 'User' or 'Computer'."
   exit
}

# Prompt the user for the name of the object
$strName = Read-Host "Please enter the $objectClass's account name (e.g. nmota for User, PC01 for Computer)"

try {
   # Get the Distinguished Name of the object
   $strDN = Get-DistinguishedName $strName $objectClass
}
catch {
   Write-Error "An error occurred while retrieving the Distinguished Name. Please check the error message and try again."
   exit
}

if ($null -ne $strDN) {
   Write-Output $strDN
}
else {
   Write-Error "No Distinguished Name was retrieved."
}