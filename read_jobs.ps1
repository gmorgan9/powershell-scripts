# Function to extract job listings from the webpage
function Get-JobListings {
    $url = "https://employment.byui.net/postings/search?query=&query_v0_posted_at_date=&query_organizational_tier_3_id=any&417=&418=8&commit=Search&_gl=1*m83aun*_ga*NDI5MDk0Mzc4LjE2ODQxOTA5Nzg.*_ga_K7FJVX9NBH*MTY4NDQ5ODA3NS4yLjEuMTY4NDQ5ODA4Ny4wLjAuMA..&_ga=2.98296667.556725209.1684498071-429094378.1684190978"
    
    # Fetch webpage content
    $webpage = Invoke-WebRequest -Uri $url
    
    # Extract job listings
    $jobListings = $webpage.ParsedHtml.getElementsByClassName("job-title")

    # Output job listings
    foreach ($job in $jobListings) {
        $job.InnerText
        Write-Host "-------------------------"
    }
}

# Call the function to get job listings
Get-JobListings
