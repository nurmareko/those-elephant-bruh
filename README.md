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

A simple Fish CLI for managing a local LAMP development environment on Fedora.

It can start and stop the LAMP services, create local development domains, configure Apache, and handle the required SELinux labels.

## Features

* Start or stop Apache, MariaDB, and PHP-FPM together
* Map project directories to local domains
* Generate Apache VirtualHost configurations
* Update `/etc/hosts` automatically
* Apply the required SELinux labels
* Remove routing without deleting project files

## Requirements

* Fedora Linux
* Fish shell
* Apache, MariaDB, PHP, and PHP-FPM

Install the required packages:

```bash
sudo dnf install httpd mariadb-server php php-fpm
```

## Installation

Download the Fish function:

```bash
curl -o ~/.config/fish/functions/elephant.fish \
  https://raw.githubusercontent.com/nurmareko/those-elephant-bruh/main/elephant.fish
```

Allow Apache to access project directories inside your home directory:

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

### Manage the LAMP stack

```bash
elephant wake
elephant sleep
elephant status
```

Available aliases:

| Command  | Aliases          | Description                        |
| -------- | ---------------- | ---------------------------------- |
| `wake`   | `start`, `up`    | Start Apache, MariaDB, and PHP-FPM |
| `sleep`  | `stop`, `down`   | Stop the services                  |
| `status` | `check`, `pulse` | Show the current service status    |

### Link a project

By default, projects are stored in `~/Projects`. You can change `BASE_DIR` inside `elephant.fish`.

```bash
elephant link example-app
```

This command:

* Creates `~/Projects/example-app` if it does not exist
* Adds a starter `index.php` when creating a new project
* Configures Apache
* Maps `example-app.test` in `/etc/hosts`
* Applies the required SELinux labels

The project will be available at:

```text
http://example-app.test
```

To use a custom local domain:

```bash
elephant link example-app example.local
```

### Unlink a project

Remove the default local domain:

```bash
elephant unlink example-app
```

Remove a custom local domain:

```bash
elephant unlink example.local
```

Unlinking removes only the Apache configuration and `/etc/hosts` entry. It does not delete or modify the project directory.
