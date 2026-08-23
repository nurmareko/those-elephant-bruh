```                                           
               ░█     █████▒▒██▒▒█████     █░               
              █░▒█████░▒█          █▒░▓████░▒█              
             █░███▓▓█████░        ░█████▓▓███░█             
            █░▓░░▓██████▒▒        ▒▒██████▓░▒▓░█            
            █░  ░   ▒███▓▒█▓    ▓█▒▓███▒   ░  ░█            
              █░░▒ ░████▒   ░  ░   ▒████░ ▒░░█              
               ██▓ ▓▒▒███░░ ░  ░ ░░███▒▒▓ ▓██               
                 ██  ▒█████░▒░░▒░█████▒  ██                 
              ░█▓█░ ███   █▒░▒▒░░█   ███ ░█▓█░              
             ██░ ░█▓    ███▓░▒▒░▓███    ▓█░ ░██             
             █▒    ░▓███▓███░▒▒░███▓███▓░    ▒█             
             █▓ ░  ▒██▓▓▓▓▓█░▓▓░█▓▓▓▓▓██▒  ░ ▓█             
             ██▓▓    ▒█▓██▓█▒▒▒▓███▓██     ▓▓██             
             ███░   █▓▓▒▒▒███▓      █      ░███             
             █▒█▒  ▓░           ▒▓██▓▒▒█▓  ▒█▒█             
             █▒░▒░       ░   ░▒█▓▒        ░▒░▒█             
              █▒ ▓▓▓▒▓█▓░░░▒▒████▒▒▒▓█▓▒▒▓▓ ▒█              
               ██  ░░▒▒▒▓█▒▓█░███████▓▒▒░  ██               
                █▓▒▒▓██████      ███████▒▒▓█                

            ▄▖▌         ▄▖▜     ▌     ▗   ▄     ▌ 
            ▐ ▛▌▛▌▛▘█▌  ▙▖▐ █▌▛▌▛▌▀▌▛▌▜▘  ▙▘▛▘▌▌▛▌
            ▐ ▌▌▙▌▄▌▙▖  ▙▖▐▖▙▖▙▌▌▌█▌▌▌▐▖  ▙▘▌ ▙▌▌▌
                              ▌                   
```

# those-elephant-bruh

A minimal Fish CLI for managing a local LAMP stack and Apache VirtualHosts on Fedora.

## Features

* Start and stop Apache, MariaDB, and PHP-FPM together
* Check the status of each service
* Link any existing project directory to a local domain
* Configure Apache and `/etc/hosts` automatically
* Apply the required SELinux context
* Remove routing without deleting project files

## Requirements

* Fedora Linux
* Fish shell
* Apache
* MariaDB
* PHP and PHP-FPM

Install the required packages:

```bash
sudo dnf install fish httpd mariadb-server php php-fpm policycoreutils
```

## Installation

Download the function into your Fish configuration:

```bash
mkdir -p ~/.config/fish/functions

curl -o ~/.config/fish/functions/elephant.fish \
  https://raw.githubusercontent.com/nurmareko/those-elephant-bruh/main/elephant.fish
```

Fish will automatically load the function when you run `elephant`.

### SELinux setup

If your projects are stored inside your home directory, allow Apache to access them:

```bash
sudo setsebool -P httpd_enable_homedirs 1
chmod a+x "$HOME"
```

This setup is only required once.

## Usage

Run `elephant` without arguments to display the available commands:

```bash
elephant
```

### Manage the stack

```bash
elephant wake
elephant sleep
elephant status
```

| Command  | Aliases          | Description                        |
| -------- | ---------------- | ---------------------------------- |
| `wake`   | `start`, `up`    | Start Apache, MariaDB, and PHP-FPM |
| `sleep`  | `stop`, `down`   | Stop all stack services            |
| `status` | `check`, `pulse` | Show the status of each service    |

### Link a project

The project directory must already exist.

Link the current directory:

```bash
cd ~/Code/example-app
elephant link .
```

The default domain is based on the directory name:

```text
http://example-app.elephant
```

You can also provide a relative or absolute path:

```bash
elephant link ./example-app
elephant link /home/user/Code/example-app
```

To use a custom domain, provide it as the second argument:

```bash
elephant link ./example-app example.local
```

This creates:

```text
./example-app → http://example.local
```

### Unlink a project

Remove a default `.elephant` domain using the project name:

```bash
elephant unlink example-app
```

Remove a custom domain using its full name:

```bash
elephant unlink example.local
```

Unlinking removes the Apache VirtualHost and `/etc/hosts` entry. The project directory and its contents are not modified.
