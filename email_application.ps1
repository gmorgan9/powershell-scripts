# Styles
# Set foreground color to green and add bold style
$greenBold = "`e[32;1m"
$redBold = "`e[31;1m"
$blueBold = "`e[34;1m"
$purpleBold = "`e[35;1m"
$yellowBold = "`e[33;1m"
$orangeBold = "`e[38;5;208;1m"

# Reset color and style
$reset = "`e[0m"

# Credentials
$username = "garrett.morgan.pro@gmail.com"
$password = "ibug tdva adpi zqxr"

# Convert the password to a secure string
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force

# Create credentials object
$credentials = New-Object System.Management.Automation.PSCredential ($username, $securePassword)

Clear-Host
Write-Host "`n`n`n`n`n`n"

# Fetch company names from the API
try {
    $companies = Invoke-RestMethod -Uri "https://db.morganserver.com/jms/api/companies.php" -Method Get
} catch {
    Write-Error "Failed to fetch company names from the API."
    exit
}

# Extract company names from the API response
$companyNames = $companies 

# Loop through each company name
foreach ($companyName in $companyNames) {
    Write-Host "${blueBold}Processing emails for company: $companyName${reset}"
    # Define an array to store email details for the current company
    $allEmailsContainingPhrase = @()

    try {
        # Invoke-GmailSession with credentials to search for read emails containing the specified phrase
        $readEmailsContainingPhrase = Invoke-GmailSession -Credential $credentials -ScriptBlock {
            param($gmail)
            $inbox = $gmail | Get-Mailbox
            $emails = $inbox | Get-Message -Read
            $emailsContainingPhrase = @()
        
            foreach ($email in $emails) {
                if ($email.Subject -like "*$companyName*") {
                    $emailDetails = [PSCustomObject]@{
                        Subject = $email.Subject
                        From = $email.From.Address
                        MessageID = $email.MessageID
                    }
                    $emailsContainingPhrase += $emailDetails
                }
            }
        
            $emailsContainingPhrase
        } 

        # Check if there are read emails containing the specified phrase
        if ($readEmailsContainingPhrase.Count -gt 0) {
            # Output the list of read emails containing the specified phrase
            Write-Host "`n"
            Write-Output "${greenBold}Read emails containing $companyName"
        
            foreach ($readEmail in $readEmailsContainingPhrase) {
                Write-Output "${yellowBold}Subject: $($readEmail.Subject)"
                Write-Output "${yellowBold}From: $($readEmail.From)"
                
                # Add email details to the array
                $allEmailsContainingPhrase += $readEmail
            }
        } else {
            # No read emails found
            Write-Host "`n"
            Write-Output "${redBold}No read emails containing $companyName found."
        }
        
        # Invoke-GmailSession with credentials to search for unread emails containing the specified phrase
        $unreadEmailsContainingPhrase = Invoke-GmailSession -Credential $credentials -ScriptBlock {
            param($gmail)
            $inbox = $gmail | Get-Mailbox
            $emails = $inbox | Get-Message -Unread
            $emailsContainingPhrase = @()
        
            foreach ($email in $emails) {
                if ($email.Subject -like "*$companyName*") {
                    $emailDetails = [PSCustomObject]@{
                        Subject = $email.Subject
                        From = $email.From.Address
                        MessageID = $email.MessageID
                    }
                    $emailsContainingPhrase += $emailDetails
                }
            }
        
            $emailsContainingPhrase
        } 

        # Check if there are unread emails containing the specified phrase
        if ($unreadEmailsContainingPhrase.Count -gt 0) {
            # Output the list of unread emails containing the specified phrase
            Write-Host "`n"
            Write-Output "${greenBold}Unread emails containing $companyName"
            Write-Host "`n"
        
            foreach ($unreadEmail in $unreadEmailsContainingPhrase) {
                Write-Output "${yellowBold}Subject: $($unreadEmail.Subject)"
                Write-Output "${yellowBold}From: $($unreadEmail.From)"
                
                # Add email details to the array
                $allEmailsContainingPhrase += $unreadEmail
            }
        } else {
            # No unread emails found
            Write-Host "`n"
            Write-Output "${redBold}No unread emails containing $companyName found."
        }
    } catch {
        Write-Error "Error occurred while processing emails for $companyName $_"
    }

    # Construct an array to store custom email objects for the current company
    $customEmailObjects = @()

    # Loop through each email containing the specified phrase for the current company
    foreach ($email in $allEmailsContainingPhrase) {
        # Create a custom email object with desired keys
        # Remove angle brackets from MessageID
        $cleanMessageID = $email.MessageID.Replace('<', '').Replace('>', '')
    
        # Create the custom email object
        $customEmailObject = [PSCustomObject]@{
            "companyName" = $companyName
            "subject" = $email.Subject
            "sender" = $email.From
            "link" = "https://mail.google.com/mail/u/0/#search/rfc822msgid:" + $cleanMessageID
        }

        # Add the custom email object to the array
        $customEmailObjects += $customEmailObject
    }

    # Convert the array of custom email objects to JSON with customized keys
    $json = $customEmailObjects | ConvertTo-Json

    # Write-Host "Data to be sent for $companyName : $json"

    # Set the headers
    $headers = @{
        "Content-Type" = "application/json"
    }

    # Send the data using Invoke-RestMethod
    $response = Invoke-RestMethod -Uri "https://db.morganserver.com/jms/api/add_email.php" -Method Post -Headers $headers -Body $json

    Write-Host "${greenBold}Emails for $companyName were successfully recorded!`n${reset}"
    Write-Host "-----------------------------------------"
}
