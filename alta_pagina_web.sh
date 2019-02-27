#!/bin/bash

rajoy=172.22.200.114
zapatero=172.22.200.117
zonadirecta=/var/cache/bind/db.kevin.gonzalonazareno.org

echo -n "Escribir nombre de usuario a crear en el equipo Servidor Zapatero: "
read usuario
ssh centos@$zapatero sudo useradd -m $usuario
password=""$usuario"$(($RANDOM%9999))"
ssh centos@$zapatero sudo 'echo '$usuario':'$password' | chpasswd'
ssh centos@$zapatero sudo systemctl restart proftpd



echo -n "Escribe el nombre de la página web a crear: "
read pagina
echo "Creando carpeta DocumentRoot de la página web a crear"
ssh centos@$zapatero sudo mkdir /var/www/$usuario
sleep 1
echo "Cambiando propietario de la carpeta /var/www/user_$usuario ..."
ssh centos@$zapatero sudo chown -R $usuario:$usuario /var/www/$usuario
sleep 1
ssh centos@$zapatero sudo touch /var/www/$usuario/index.html
sudo scp ./ejemplo-index.html root@$zapatero:/var/www/$usuario/index.html 1> /dev/null
ssh centos@$zapatero sudo sed -i s/'paginaweb'/$pagina/g /var/www/$usuario/index.html
ssh centos@$zapatero sudo systemctl restart httpd



sudo scp ./ejemplo-host.conf centos@$zapatero:/etc/httpd/sites-available/$pagina.conf 1> /dev/null
ssh centos@$zapatero sudo sed -i s/'paginaweb'/$usuario/g /etc/httpd/sites-available/$pagina.conf
ssh centos@$zapatero sudo ln -s /etc/httpd/sites-available/$pagina.conf /etc/httpd/sites-enabled/$pagina.conf
ssh centos@$zapatero sudo systemctl restart httpd



cname=""$pagina"    IN      CNAME   zapatero"
ssh debian@$rajoy 'echo '$cname' >> '$zonadirecta''
ssh debian@$rajoy sudo systemctl restart bind9
ssh debian@$rajoy sudo rndc reload 1> /dev/null



echo "Página: "$pagina".kevin.gonzalonazareno.org"
echo "Usuario ftp: "$usuario""
echo "Contraseña: "$password""

#Añade entrada de la página web al Servidor DNS (Equipo Servidor Rajoy)

# echo "Añadiendo entrada al fichero de resolución directa en el Servidor DNS"
# ssh debian@$rajoy sudo echo "$pagina	IN	CNAME	zapatero >> /var/cache/bind/db.kevin.gonzalonazareno.org"
# sleep 2

#Reinicia el Servidor DNS (Equipo Servidor Rajoy)

#echo "Reiniciando Servidor DNS"
#ssh debian@$rajoy sudo systemctl restart bind9
#sleep 2

#Crea un nuevo usuario en el sistema (Equipo Servidor Zapatero)

#echo "Creando el usuario en el sistema"

#ssh centos@$zapatero sudo useradd user_$usuario


#echo "Cambiando propietario de la carpeta /var/www/user_$usuario ..."

#ssh centos@$zapatero sudo chown -R user_$usuario:user_$usuario /var/www/user_$usuario
#sleep 1

#Crea el fichero de configuración de la página web a crear (Equipo Servidor Zapatero)

#echo "Creando fichero de configuración del sitio web $pagina.kevin.gonzalonazareno.org..."

#ssh centos@$zapatero sudo touch /etc/httpd/sites-available/$pagina.conf
#ssh centos@$zapatero sudo chmod 646 /etc/httpd/sites-available/$pagina.conf
#ssh centos@$zapatero sudo echo "<VirtualHost *:80>" >> /etc/httpd/sites-available/$pagina.conf
#ssh centos@$zapatero sudo echo "ServerName $pagina.kevin.gonzalonazareno.org >> /etc/httpd/sites-available/$pagina.conf"
#ssh centos@$zapatero sudo echo "DocumentRoot /var/www/user_$usuario >> /etc/httpd/sites-available/$pagina.conf"
#ssh centos@$zapatero sudo echo "<Directory /var/www/user_$usuario>" >> /etc/httpd/sites-available/$pagina.conf
#ssh centos@$zapatero sudo echo "Options Indexes SymLinksIfOwnerMatch >> /etc/httpd/sites-available/$pagina.conf"
#ssh centos@$zapatero sudo echo "AllowOverride None >> /etc/httpd/sites-available/$pagina.conf"
#ssh centos@$zapatero sudo echo "Require all granted >> /etc/httpd/sites-available/$pagina.conf"
#ssh centos@$zapatero sudo echo "</Directory>" >> /etc/httpd/sites-available/$pagina.conf
#ssh centos@$zapatero sudo echo "</VirtualHost>" >> /etc/httpd/sites-available/$pagina.conf

#Activa el sitio web (Equipo Servidor Zapatero)

#echo "Activando sitio web..."

#ssh centos@$zapatero sudo ln -s /etc/httpd/sites-available/$pagina.conf /etc/httpd/sites-enabled/$pagina.conf
#sleep 1

#Reinicia el Servidor Web (Equipo Servidor Zapatero)

#echo "Reiniciando Servidor Web..."

#ssh centos@$zapatero sudo systemctl restart httpd
#sleep 2

#Asignar contraseña al usuario creado (Equipo Servidor Zapatero)

# ssh centos@$zapatero sudo passwd user_$usuario

#Crear usuario en el Sistema Gestor de Base de Datos MySQL

#ssh ubuntu@$aznar mysql -u root -p
