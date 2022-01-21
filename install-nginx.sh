#! /bin/bash
sudo apt-get update
sudo apt-get upgrade -y
sudo apt install nginx -y
echo "<body bgcolor=\"#C83C01\" style=\"color:#FFFFFF;\"><br><br><br><H1 align=\"middle\">Kyndryl Use Case 3 Demonstration</H1>" | sudo tee /var/www/html/index.html
echo "<H4 align=\"middle\">Diese Seite wurde ihnen praesentiert von WebServer</H4><H1 align=\"middle\">" | sudo tee -a /var/www/html/index.html
echo $HOSTNAME | sudo tee -a /var/www/html/index.html
echo "</H1></body>" | sudo tee -a /var/www/html/index.html