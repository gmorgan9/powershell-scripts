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

# Clear the console
Clear-Host
Write-Host "`n`n`n`n`n`n"
Write-Host "${blueBold}Please enter a url for the job you want to record!`n${reset}"

# Prompt user for URL

$url = Read-Host "Enter a URL"

# Make web request and get response HTML
$response = Invoke-WebRequest -Uri $url -UseBasicParsing
$html = $response.Content

# Job Title
if ($html -match '<h1.*?class=".*?topcard__title.*?">(?<title>.*?)<\/h1>') {
    $title = $Matches['title']
} else {
    $title = 'Job title not found'
}

# Company
if ($html -match '<a.*?class="topcard__org-name-link.*?">(?<company>[^<]+)<\/a>') {
    $company = $Matches['company'].Trim()
} else {
    $company = 'Company not found'
}

# Location
if ($html -match '(?i)remote') {
    $location = 'Remote'
} elseif ($html -match '<span.*?class="topcard__flavor.*?>(?<location>[^<]+)<\/span>') {
    $location = $Matches['location'].Trim()
} else {
    $location = 'Location not found'
}

# Job Type
if ($html -match '(?i)full[-\s]?time') {
    $jobType = 'Full-time'
} elseif ($html -match '(?i)part[-\s]?time') {
    $jobType = 'Part-time'
} elseif ($html -match '(?i)contract') {
    $jobType = 'Contract'
} elseif ($html -match '(?i)internship') {
    $jobType = 'Internship'
} else {
    $jobType = 'Job type not found'
}

# Function to prompt for editing a specific field
function EditField($fieldName, $currentValue) {
    $editConfirmation = Read-Host "Do you want to edit $fieldName? Current value is '$currentValue'. (Y/N)"
    if ($editConfirmation -eq "Y" -or $editConfirmation -eq "y") {
        $newValue = Read-Host "Enter new value for $fieldName"
        if (![string]::IsNullOrWhiteSpace($newValue)) {
            return $newValue
        }
    }
    return $currentValue
}

# Output job information to console
Write-Host "`n`n${greenBold}Job Link:${reset} $url"
Write-Host "${greenBold}Job Title:${reset} $title"
Write-Host "${greenBold}Company Name:${reset} $company"
Write-Host "${greenBold}Location:${reset} $location"
Write-Host "${greenBold}Job Type:${reset} $jobType"

Write-Host "`n`n"

# Prompt if user wants to edit any current fields
$editConfirmation = Read-Host "Do you want to edit any of the current fields? (Y/N)"
if ($editConfirmation -eq "Y" -or $editConfirmation -eq "y") {
    # Prompt for editing each field
    # $url = EditField "App Link" $url
    $title = EditField "Job Title" $title
    $company = EditField "Company Name" $company
    $location = EditField "Location" $location
    $jobType = EditField "Job Type" $jobType

    # Output newly updated fields
    Write-Host "`n`n${greenBold}Updated Fields:${reset}"
    Write-Host "${greenBold}Job Link:${reset} $url"
    Write-Host "${greenBold}Job Title:${reset} $title"
    Write-Host "${greenBold}Company Name:${reset} $company"
    Write-Host "${greenBold}Location:${reset} $location"
    Write-Host "${greenBold}Job Type:${reset} $jobType"
}

Write-Host "`n`n"

# Confirm before inserting job data into database
$confirmation = Read-Host "`nAre you ready to insert this job data into the database? (Y/N)"
if ($confirmation -eq "Y" -or $confirmation -eq "y") {
    # Set the connection parameters

    # Define the data as a hashtable
    $data = @{
        job_link = $url
        job_title = $title
        company = $company
        location = $location
        job_type = $jobType
    }

    # Convert the hashtable to a JSON string
    $json = $data | ConvertTo-Json

    # Set the headers
    $headers = @{
        "Content-Type" = "application/json"
    }

    # Send the data using Invoke-RestMethod
    $response = Invoke-RestMethod -Uri "https://careerhub.morganserver.com/api/add_job.php" -Method Post -Headers $headers -Body $json

    Write-Host "${greenBold}Application was successfully recorded!`n${reset}"
} else {
    Write-Host "${redBold}Job data was not inserted into the database.`n${reset}"
}
