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

Last but not least run the script **(be aware that on some systems you may need to be super user to complete the configuration)**:
```
./setup.sh
```

### Run flake

```nix
nix run github:MikaelFangel/DTUconnect
```

### Usage as a flake

[![FlakeHub](https://img.shields.io/endpoint?url=https://flakehub.com/f/MikaelFangel/DTUConnect/badge)](https://flakehub.com/flake/MikaelFangel/DTUConnect)

Add DTUConnect to your `flake.nix`:

```nix
{
  inputs.DTUConnect.url = "https://flakehub.com/f/MikaelFangel/DTUConnect/*.tar.gz";

  outputs = { self, DTUConnect }: {
    # Use in your outputs
  };
}

```

### Requirements
* NetworkManager or iwd
* Awk
