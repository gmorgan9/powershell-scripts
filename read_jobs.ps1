
# Load environment variables from .env file
$envFilePath = ".env"
if (Test-Path $envFilePath) {
    $envVars = Get-Content $envFilePath | ForEach-Object {
        if ($_ -match '\s*([^=]+)\s*=\s*(.+)') {
            [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2], "Process")
            Set-Variable -Name $matches[1] -Value $matches[2]
        }
    }
}



# Make web request and get response HTML
$response = Invoke-WebRequest -Uri "https://employment.byui.net/postings/search?query=&query_v0_posted_at_date=&query_organizational_tier_3_id=any&417=&418=8&commit=Search&_gl=1*m83aun*_ga*NDI5MDk0Mzc4LjE2ODQxOTA5Nzg.*_ga_K7FJVX9NBH*MTY4NDQ5ODA3NS4yLjEuMTY4NDQ5ODA4Ny4wLjAuMA..&_ga=2.98296667.556725209.1684498071-429094378.1684190978" -UseBasicParsing
$html = $response.Content

# Job Titles
$jobTitles = @()
$matches = [regex]::Matches($html, '<div class="job-title col-md-4">\s*<h3>\s*<a[^>]*>(.*?)<\/a>\s*<\/h3>\s*<\/div>')
foreach ($match in $matches) {
    $jobTitles += $match.Groups[1].Value
}

# Count number of job postings
$jobCount = $jobTitles.Count

# Output job count and titles
Write-Host "Number of Job Postings: $jobCount"
Write-Host "Job Titles:"
foreach ($title in $jobTitles) {
    Write-Host $title
}

# Prepare message for Slack
$message = @{
    blocks = @(
        @{
            type = "section"
            text = @{
                type = "plain_text"
                text = "Number of Job Postings: $jobCount`n`nJob Titles:`n$($jobTitles -join "`n")"
            }
        },
        @{
            type = "section"
            text = @{
                type = "mrkdwn"
                text = "This is a section block with a button."
            }
            accessory = @{
                type = "button"
                text = @{
                    type = "plain_text"
                    text = "View Website"
                    emoji = $true
                }
                url = "https://employment.byui.net/postings/search?query=&query_v0_posted_at_date=&query_organizational_tier_3_id=any&417=&418=8&commit=Search&_gl=1*m83aun*_ga*NDI5MDk0Mzc4LjE2ODQxOTA5Nzg.*_ga_K7FJVX9NBH*MTY4NDQ5ODA3NS4yLjEuMTY4NDQ5ODA4Ny4wLjAuMA..&_ga=2.98296667.556725209.1684498071-429094378.1684190978"
            }
        }
    )
}

# Convert the message to JSON
$jsonMessage = $message | ConvertTo-Json -Depth 5


# Send message to Slack
Invoke-RestMethod -Uri $env:SLACK_WEBHOOK_URL -Method Post -Body $jsonMessage -ContentType 'application/json'


