# Define your Jira organization ID, API token, and Jira project details
$JiraUrl = "https://garrett-morgan.atlassian.net/rest/api/2/issue/"
$OrganizationId = "2d11387j-3068-1011-jakj-26bb10b21db7"
$ApiToken = ""
$ProjectKey = "MS"

# Define the JSON payload for creating a Jira issue
$JsonPayload = @{
    "fields" = @{
        "project" = @{
            "key" = $ProjectKey
        }
        "summary" = "Your issue summary"
        "description" = "Your issue description"
        "issuetype" = @{
            "name" = "Problem"  # You can change the issue type as needed
        }
    }
} | ConvertTo-Json

# Define headers for authentication
$headers = @{
    "Authorization" = "Basic {0}" -f [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $OrganizationId, $ApiToken)))
    "Content-Type" = "application/json"
}

# Create the Jira issue using REST API
$response = Invoke-RestMethod -Uri $JiraUrl -Method Post -Body $JsonPayload -Headers $headers

# Check if the ticket was created successfully
if ($response) {
    Write-Host "Ticket created successfully. Key: $($response.key)"
} else {
    Write-Host "Failed to create ticket."
}
