# Function to scrape job title from HTML content
function GetJobTitleFromHTML {
    param (
        [string]$htmlContent
    )
    
    # Define the regex pattern to match the job title
    $pattern = '<h2 class="jobsearch-JobInfoHeader-title[^>]*>(.*?)<\/h2>'
    
    # Use regex to extract the job title
    $jobTitle = [regex]::Match($htmlContent, $pattern).Groups[1].Value
    
    return $jobTitle
}

# Main script
$url = Read-Host "Enter the URL to scrape from"

try {
    # Fetch HTML content from the URL
    $response = Invoke-WebRequest -Uri $url -Headers @{
        'User-Agent' = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.110 Safari/537.36'
    }
    
    # Scrape job title from HTML content
    $jobTitle = GetJobTitleFromHTML $response.Content

    # Output the scraped job title
    if (-not [string]::IsNullOrEmpty($jobTitle)) {
        Write-Host "Scraped job title: $jobTitle"
    } else {
        Write-Host "Job title not found in the HTML content."
    }
}
catch {
    Write-Host "Error occurred while fetching HTML content: $_"
}
