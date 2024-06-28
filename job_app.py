import requests
from bs4 import BeautifulSoup

# Styles
greenBold = "\033[32;1m"
redBold = "\033[31;1m"
reset = "\033[0m"

# Clear the console
print("\n\n\n\n\n\n\n")

print(f"{greenBold}Please enter a URL for the application you want to record!{reset}")

# Prompt user for URL
url = input("Enter a URL: ")

# Make web request and get response HTML
response = requests.get(url)
html = response.text

# Extract job information using BeautifulSoup
soup = BeautifulSoup(html, 'html.parser')

# Extract job title
title_element = soup.find('h1', class_='topcard__title')
title = title_element.text.strip() if title_element else "Job Title not found"

# Extract company name
company_element = soup.find('a', class_='topcard__org-name-link')
company = company_element.text.strip() if company_element else "Company Name not found"

# Extract location
location_element = soup.find('span', class_='topcard__flavor')
location = location_element.text.strip() if location_element else "Location not found"

# Extract job type
job_type_element = soup.find(string=lambda text: 'full-time' in text.lower() or 'part-time' in text.lower() or 'contract' in text.lower() or 'internship' in text.lower())
job_type = job_type_element.strip() if job_type_element else "Job Type not found"

# Output job information to console
print(f"\n\n{greenBold}App Link:{reset} {url}")
print(f"{greenBold}Job Title:{reset} {title}")
print(f"{greenBold}Company Name:{reset} {company}")
print(f"{greenBold}Location:{reset} {location}")
print(f"{greenBold}Job Type:{reset} {job_type}")

# Prompt if user wants to edit any current fields
edit_confirmation = input("\n\nDo you want to edit any of the current fields? (Y/N): ")
if edit_confirmation.upper() == "Y":
    # Implement editing logic if needed
    pass

# Confirm before inserting job data into database
confirmation = input("\nAre you ready to insert this job data into the database? (Y/N): ")
if confirmation.upper() == "Y":
    # Define the data as a dictionary
    data = {
        "app_link": url,
        "job_title": title,
        "company": company,
        "location": location,
        "job_type": job_type
    }

    # Send the data using requests
    response = requests.post("https://db.morganserver.com/api/add_application.php", json=data)

    if response.status_code == 200:
        print(f"{greenBold}Application was successfully recorded!{reset}")
    else:
        print(f"{redBold}Failed to record application.{reset}")
else:
    print(f"{redBold}Job data was not inserted into the database.{reset}")
