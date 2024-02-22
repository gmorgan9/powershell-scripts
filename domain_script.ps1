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
$domain = Read-Host "${blueBold}Enter the domain name (e.g., example.com)"
$port = Read-Host "Enter the desired port`n${reset}"

# Construct the command with the provided domain
$cmd1 = "sudo mkdir -p /var/www/$domain/public_html"

# Execute the command
Invoke-Expression $cmd1

$cmd2 = "sudo chmod -R 755 /var/www"

# Execute the command
Invoke-Expression $cmd2

$cmd3 = "sudo touch /var/www/$domain/public_html/index.html"

# Execute the command
Invoke-Expression $cmd3

$cmd4 = "echo 'Hello, world! Testing from $domain!' | sudo tee -a /var/www/$domain/public_html/index.html"

# Execute the command
Invoke-Expression $cmd4

$cmd5 = "echo '<VirtualHost *:$port>
ServerAdmin webmaster@localhost
ServerName http://$domain.com 
ServerAlias http://www.$domain.com 
DocumentRoot /var/www/$domain/public_html
ErrorLog $%{APACHE_LOG_DIR}/error.log
CustomLog $%{APACHE_LOG_DIR}/access.log combined
</VirtualHost>' | sudo tee -a /etc/apache2/sites-available/$domain.conf ; sudo sed -i 's/\%//g' /etc/apache2/sites-available/$domain.conf"

# Execute the command
Invoke-Expression $cmd5

$cmd6 = "echo 'Listen $port' | sudo tee -a /etc/apache2/ports.conf"

# Execute the command
Invoke-Expression $cmd6

$cmd7 = "sudo a2dissite 000-default.conf"

# Execute the command
Invoke-Expression $cmd7

$cmd8 = "sudo a2ensite $domain.conf"

# Execute the command
Invoke-Expression $cmd8

$cmd9 = "sudo systemctl restart apache2"

# Execute the command
Invoke-Expression $cmd9


Write-Host "${greenBold}Process completed successfully.`n${reset}"
