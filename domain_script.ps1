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


Clear-Host
Write-Host "`n`n`n`n`n`n"

# Prompt the user for input
$dir = Read-Host "${blueBold}Enter the directory name"
$port = Read-Host "Enter the desired port"
$domain = Read-Host "Enter the domain (e.g., example.com)"

${reset}

# Construct the command with the provided domain
$cmd1 = "sudo mkdir -p /var/www/$dir/public_html"

# Execute the command
Invoke-Expression $cmd1

$cmd2 = "sudo chmod -R 755 /var/www"

# Execute the command
Invoke-Expression $cmd2

$cmd3 = "sudo touch /var/www/$dir/public_html/index.html"

# Execute the command
Invoke-Expression $cmd3

$cmd4 = "echo 'Hello, world! Testing from $dir!' | sudo tee -a /var/www/$dir/public_html/index.html"

# Execute the command
Invoke-Expression $cmd4

$cmd5 = "echo '<VirtualHost *:$port>
ServerAdmin webmaster@localhost
ServerName http://$domain 
ServerAlias http://www.$domain 
DocumentRoot /var/www/$dir/public_html
ErrorLog $%{APACHE_LOG_DIR}/error.log
CustomLog $%{APACHE_LOG_DIR}/access.log combined
</VirtualHost>' | sudo tee -a /etc/apache2/sites-available/$dir.conf ; sudo sed -i 's/\%//g' /etc/apache2/sites-available/$dir.conf"

# Execute the command
Invoke-Expression $cmd5

$cmd6 = "echo 'Listen $port' | sudo tee -a /etc/apache2/ports.conf"

# Execute the command
Invoke-Expression $cmd6

$cmd7 = "sudo a2dissite 000-default.conf"

# Execute the command
Invoke-Expression $cmd7

$cmd8 = "sudo a2ensite $dir.conf"

# Execute the command
Invoke-Expression $cmd8

$cmd9 = "sudo systemctl restart apache2"

# Execute the command
Invoke-Expression $cmd9


# Prompt the user if they have a GitHub repository
$response = Read-Host "${blueBold}Do you have a GitHub repository to copy over? (yes/no)"

${reset}

# Check the user's response
if ($response -eq "yes") {
    # If yes, ask for the GitHub repository link
    $githubRepo = Read-Host "${blueBold}Enter the GitHub repository link"

    ${reset}
    
    # Change directory to the public_html folder
    cd "/var/www/$domain/public_html/"
    
    # Run git clone command
    sudo git clone $githubRepo
} 
else {
    # If no, display message
    Write-Host "${orangeBold}Github repository not pulled in"
}


Clear-Host
Write-Host "`n`n`n`n`n`n"

$checkMark = [char]0x2713

Write-Host "${greenBold}$checkMark Process completed successfully."

${reset}