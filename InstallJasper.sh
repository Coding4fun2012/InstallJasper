#!/bin/bash
cd ~

sudo apt-get update

sudo apt-get upgrade --yes

sudo apt-get install nano espeak git-core python-dev python-pip bison libasound2-dev libportaudio-dev python-pyaudio --yes

echo"
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/lib
source .bashrc
PATH=$PATH:/usr/local/lib/
export PATH" > ~/.bash_profile
source ~/.bash_profile

# Install Jasper
git clone https://github.com/jasperproject/jasper-client.git jasper
sudo pip install --upgrade setuptools
sudo pip install -r jasper/client/requirements.txt
chmod +x jasper/jasper.py

# Install Festival TTS
sudo apt-get install festival festvox-don --yes

# Install Pocketsphinx STT
wget http://downloads.sourceforge.net/project/cmusphinx/sphinxbase/0.8/sphinxbase-0.8.tar.gz
wget http://downloads.sourceforge.net/project/cmusphinx/pocketsphinx/0.8/pocketsphinx-0.8.tar.gz
tar -zxvf sphinxbase-0.8.tar.gz
tar -zxvf pocketsphinx-0.8.tar.gz 
cd ~/sphinxbase-0.8/
./configure --enable-fixed
make
sudo make install
cd ~/pocketsphinx-0.8/
./configure
make
sudo make install 
cd ~
rm -rf sphinxbase-0.8 sphinxbase-0.8.tar.gz pocketsphinx-0.8 pocketsphinx-0.8.tar.gz

# Install Pocketsphinx dependencies
sudo apt-get install subversion autoconf libtool automake gfortran g++ --yes
svn co https://svn.code.sf.net/p/cmusphinx/code/trunk/cmuclmtk/
cd cmuclmtk/
sudo ./autogen.sh && sudo make && sudo make install
cd ~
rm -rf cmuclmtk

wget http://distfiles.macports.org/openfst/openfst-1.3.3.tar.gz
wget https://mitlm.googlecode.com/files/mitlm-0.4.1.tar.gz
wget https://m2m-aligner.googlecode.com/files/m2m-aligner-1.2.tar.gz
wget https://phonetisaurus.googlecode.com/files/phonetisaurus-0.7.8.tgz
wget http://phonetisaurus.googlecode.com/files/g014b2b.tgz

tar -xvf m2m-aligner-1.2.tar.gz
tar -xvf openfst-1.3.3.tar.gz
tar -xvf phonetisaurus-0.7.8.tgz
tar -xvf mitlm-0.4.1.tar.gz
tar -xvf g014b2b.tgz 

cd ~/openfst-1.3.3/
sudo ./configure --enable-compact-fsts --enable-const-fsts --enable-far --enable-lookahead-fsts --enable-pdt
sudo make install
cd ~

cd ~/m2m-aligner-1.2/
sudo make
cd ~

cd ~/mitlm-0.4.1/
sudo ./configure
sudo make install
cd ~

cd ~/phonetisaurus-0.7.8/
cd src
sudo make
cd ~

sudo cp ~/m2m-aligner-1.2/m2m-aligner /usr/local/bin/m2m-aligner
sudo cp ~/phonetisaurus-0.7.8/phonetisaurus-g2p /usr/local/bin/phonetisaurus-g2p

cd g014b2b/
./compile-fst.sh 
mv ~/g014b2b ~/phonetisaurus 
cd ~

rm -rf m2m-aligner-1.2.tar.gz openfst-1.3.3.tar.gz phonetisaurus-0.7.8.tgz mitlm-0.4.1.tar.gz g014b2b.tgz m2m-aligner-1.2 openfst-1.3.3 phonetisaurus-0.7.8 mitlm-0.4.1

# Populate And Configure Jasper
cd ~/jasper/client
python populate.py
cd ~

echo ""
echo "Change the following line:"
echo "options snd-usb-audio index=-2"
echo ""
echo "To this:"
echo "options snd-usb-audio index=0"
echo ""

read -p "Press [Enter] key to start editing..."

sudo nano /etc/modprobe.d/alsa-base.conf 
sudo alsa force-reload

echo "Test your sound config via:"
echo "arecord temp.wav"
echo "aplay temp.wav"
echo "rm temp.wav"
echo ""

echo "Run Jasper:"
echo "~/jasper/jasper.py"
echo ""
echo "You maybe want to add that line to /etc/rc.local:"
echo "sudo -su <user> screen -dmS \"Jasper\" ~/jasper/jasper.py"
echo ""

read -p "Press [Enter] key to start jasper..."
~/jasper/jasper.py
