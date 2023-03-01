# DTUConnect
This script is made to make it easier to connect to the university WiFi and is meant as a help to new students running Linux. This short setup will allow students to setup both a connection to DTUsecure and eduroam at the same time. The script can be run from anywhere and you don't need to be in the proximity of a DTUsecure/eduroam access point. The next time you come within range it will try to connect.  

As when you normally connect to DTUsecure/eduroam your username is your studentmail @dtu.dk and the same password as normally used for that account. If you for some reason type anything wrong and finished the script. Just re-run it. It will prompt you to delete your old configuration file.

## How to use
Download and open the project by running the following command in the terminal:

```
git clone https://github.com/MikaelFangel/DTUConnect.git && cd DTUConnect 
```

Next make sure that setup.sh is executable:

```
chmod +x ./setup.sh
```

Last but not least run the script:
```
./setup.sh
```

### Requirements
* NetworkManager
* Awk

## How to setup for embedded devices
The connman mode can be use to setup embedded devices such as a Lego EV3 device running ev3dev.

Make sure that the scripts are executeable
```
chmod +x ./connman.sh ./setup.sh
```

Then run the script on the embedded device
```
sudo ./setup -c
```

### Requirements
* connmann
