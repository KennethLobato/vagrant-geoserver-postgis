# Install PostGIS
echo *** Installing PostGIS ***
	sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt xenial-pgdg main" >> /etc/apt/sources.list'
	wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | sudo apt-key add -
	sudo apt-get update
	sudo apt-get install -y postgresql-9.6
	sudo apt-get install -y postgresql-9.6-postgis-2.3 postgresql-contrib-9.6 postgresql-9.6-postgis-scripts
	sudo apt-get install -y postgis
	sudo apt-get install -y postgresql-9.6-pgrouting

	#sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt trusty-pgdg main" >> /etc/apt/sources.list'
	#wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -
	#sudo apt-add-repository -y ppa:georepublic/pgrouting
  #  sudo apt-get update
	#sudo apt-get install -y postgresql-9.4-postgis-2.1 pgadmin3 postgresql-contrib libssl-dev



# Enable Adminpack
#	sudo -u postgres psql
#	CREATE EXTENSION adminpack;
#	service postgresql restart
#	SELECT pg_reload_conf();
#	SELECT name, setting FROM pg_settings where category='File Locations';
#	\q
#	sudo su - postgres
# Create user - note change it from postgisuser
#	createuser -d -E -i -l -P -r -s postgisuser
#	echo "default postgres user <postgisuser> created - please change"

# Install pgRouting package (for Ubuntu 14.04)
# sudo apt-get install postgresql-9.4-pgrouting
echo ' '
echo --- PostGIS Installed - note there will be post-configuration steps needed ---

echo ' Installing Oracle Java 8'
sudo apt-get install -y python-software-properties debconf-utils
sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
sudo apt-get install -y oracle-java8-installer
# Install Java Criptography Extension 
sudo apt install -y oracle-java8-unlimited-jce-policy

# Config JRE - still needs to be fixed
#JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
#export JAVA_HOME

echo ' '
echo --- Installing unzip ---

# Install unzip
sudo apt-get install -y unzip

echo ' '
echo --- Setting Up for GeoServer ---
echo "export GEOSERVER_HOME=/usr/local/geoserver/" >> ~/.profile
. ~/.profile

#sudo rm -rf /usr/local/geoserver/
#mkdir /usr/local/geoserver/
#sudo chown -R vagrant /usr/local/geoserver/

cd /usr/local

echo ' '
echo --- Downloading GeoServer package - please wait ---
if [ ! -f /vagrant/geoserver.zip ]; then wget -nv -O /vagrant/geoserver.zip https://sourceforge.net/projects/geoserver/files/GeoServer/2.12.1/geoserver-2.12.1-bin.zip; fi
sudo unzip /vagrant/geoserver.zip -d /usr/local/

echo ' '
echo --- Package unzipped - configuring GeoServer directory ---
ln -sf /usr/local/geoserver-2.12.1 /usr/local/geoserver

echo ' '
echo --- GeoServer Installed ---

echo ' '
echo --- Getting ready to run GeoServer ---

sudo chown -R ubuntu /usr/local/geoserver/

cd /usr/local/geoserver/bin

# Geoserver configuration - use /etc/default/geoserver to override these vars
# user that shall run GeoServer
USER=geoserver
GEOSERVER_DATA_DIR=/home/$USER/data_dir
export GEOSERVER_DATA_DIR
#GEOSERVER_HOME=/home/$USER/geoserver
GEOSERVER_HOME=/usr/local/geoserver/
export GEOSERVER_HOME

PATH=/usr/sbin:/usr/bin:/sbin:/bin
DESC="GeoServer daemon"
NAME=geoserver
JAVA_OPTS="-Xms128m -Xmx512m"
DAEMON="$JAVA_HOME/bin/java"
PIDFILE=/var/run/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME

# Read configuration variable file if it is present
[ -r /etc/default/$NAME ] && . /etc/default/$NAME

DAEMON_ARGS="$JAVA_OPTS $DEBUG_OPTS -DGEOSERVER_DATA_DIR=$GEOSERVER_DATA_DIR -Djava.awt.headless=true -jar start.jar"

# Load the VERBOSE setting and other rcS variables
[ -f /etc/default/rcS ] && . /etc/default/rcS

# Define LSB log_* functions.
# Depend on lsb-base (>= 3.0-6) to ensure that this file is present.
. /lib/lsb/init-functions

echo ' '
echo --- Launching GeoServer startup script ---
echo --- This will run in the background with nohup mode ---
echo --- To access the server, use vagrant ssh ---
echo --- To view the web client go to http://localhost:8080/geoserver ---
echo ' '

# run startup script and have it run in the background - output logged to nohup.out

echo "USER is" $USER
echo "GEOSERVER_DATA_DIR is" $GEOSERVER_DATA_DIR
echo "GEOSERVER_HOME is " $GEOSERVER_HOME

cd /usr/local/geoserver/bin/
echo " "
echo "Working directory:"
pwd
echo "--------"
echo "Starting up GeoServer"
sh /usr/local/geoserver/bin/startup.sh 0<&- &>/dev/null &
