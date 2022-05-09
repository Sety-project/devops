sudo yum groupinstall "Development tools" -y
echo "Installing perl regex"
sudo yum install -y pcre-devel
echo "Installing compiling stuff"
sudo yum install xz-devel -y
echo "Installing git"
sudo yum install git

cd /usr/local/src
sudo git clone https://github.com/ggreer/the_silver_searcher.git
cd the_silver_searcher
sudo -i root
./build.sh
make install
# optional - making an alias right away
alias ag="/usr/local/bin/ag"
su $USER
