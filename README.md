# IPTables Port Manager

`iptables_port_manager` is a project that facilitates the dynamic management of port forwarding using iptables and systemd on a Linux system. It is particularly useful for handling a large number of backtunnels from local VMs over NAT to a remote VPS with a public IP, without needing to keep all of them open all the time. The ports are opened only when needed and closed automatically after an SSH connection is established.

## Features
- Automatically opens and closes ports using iptables.
- Operates as a systemd service running an infinite bash loop.
- Useful for managing backtunnels with minimal open ports.

## Prerequisites
- Linux system with root privileges.
- `iptables` installed on the system.
- `systemd` installed and running.

## Installation

1. **Clone the Repository:**
    ```sh
    git clone https://github.com/uxumax/iptables_port_manager.git
    cd iptables_port_manager
    ```

2. **Run the Installation Script:**
    The `install.sh` script will copy necessary files, set appropriate permissions, and enable and start the systemd service.
    ```sh
    sudo ./install.sh
    ```

## Usage

Once installed, the service will automatically start and run the `port_manager.sh` script in an infinite loop. This script reads port numbers from `/tmp/ports_to_open.list`, opens them, and then closes them after a set time delay.

**To open a port:**
- Add the port number to the `/tmp/ports_to_open.list` file.

Example:
```sh
echo "2222" >> /tmp/ports_to_open.list
```

The service will automatically detect the new port in the list, open it, and close it after a delay.

Better way set 600 privileges to this file but this depends on your case:
```sh
chmod 600 /tmp/ports_to_open.list
```

You can change path `ports_to_open.list` to any place. 
Just change `PORTS_FILE` value in `./port_manager.sh` script if before run installation or in `/usr/sbin/port_manager.sh` if already installed:
```sh
PORTS_FILE="your/new/better/place/ports_to_open.list"
```

## Related projects
- [ossh](https://github.com/uxumax/ossh) - simple SSH wrapper that allows you to run custom scripts before and after an SSH connection is established. You can open a port by simply adding a command to `~/.ssh/before_installed.sh` that adds the port number to `$PORTS_FILE` on your server.

## License
[MIT License](LICENSE)

## Contributing

Feel free to fork the project and submit pull requests. For major changes, please open an issue to discuss what you would like to change.

## Author
- [uxumax](https://github.com/uxumax)
