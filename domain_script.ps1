Clear-Host
Write-Host "`n`n`n`n`n`n"

# # Prompt the user for input
# $domain = Read-Host "Enter the domain name (e.g., example.com)"

# # Construct the command with the provided domain
# $cmd1 = "sudo mkdir -p /var/www/$domain/public_html"

# # Execute the command
# Invoke-Expression $cmd1

# $cmd2 = "sudo chmod -R 755 /var/www"

# # Execute the command
# Invoke-Expression $cmd2

# $cmd3 = "sudo nano /var/www/$domain/public_html/index.html"

# # Execute the command
# Invoke-Expression $cmd3


# Ask for input to replace "domain.com" portion
$domain = Read-Host "Enter domain name (e.g., example.com)"

# Create directory
sudo mkdir -p "/var/www/$domain/public_html"

# Set permissions
sudo chmod -R 755 "/var/www"

# Create index.html file
sudo nano "/var/www/$domain/public_html/index.html"
Write-Output "testing for $domain" | sudo tee "/var/www/$domain/public_html/index.html"

# Copy default Apache config and edit it
sudo cp "/etc/apache2/sites-available/000-default.conf" "/etc/apache2/sites-available/$domain.conf"
sudo nano "/etc/apache2/sites-available/$domain.conf"
$port = Read-Host "Enter port number"
$confText = @"
<VirtualHost *:$port>
ServerAdmin webmaster@localhost
ServerName http://$domain
ServerAlias http://www.$domain
DocumentRoot /var/www/$domain/public_html
ErrorLog \${APACHE_LOG_DIR}/error.log
CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
"@
echo $confText | sudo tee "/etc/apache2/sites-available/$domain.conf"

# Edit ports.conf
sudo sed -i "\$aListen $port" "/etc/apache2/ports.conf"

# Disable default site and enable new site
sudo a2dissite 000-default.conf
sudo a2ensite "$domain.conf"

# Restart Apache
sudo systemctl restart apache2




Write-Host "Process completed successfully."


