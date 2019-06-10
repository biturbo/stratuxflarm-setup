An alternative method for installing Stratux on your board's Linux OS.

The script is currently in beta development.

Commands to run the setup script:

    [login via command line]

    # sudo su -
    # sudo apt install git
    
    [Raspberry Pi boards]

    # raspi-config
        select option 1 - expand filesystem
        reboot

    # cd /root

    # git clone https://github.com/biturbo/stratuxflarm-setup
    # cd stratuxflarm-setup

    # bash stratuxflarm-setup.sh
        - currently detected boards: RPi3
        - note, the setup script performs a dist-upgrade, if it's the
        first time the setup may take a considerable amount of time

    # reboot


Requirements:

    - Linux compatible board
    - Linux OS
    - apt-get
    - ethernet connection
    - wifi
    - keyboard
    - a little command line fu
