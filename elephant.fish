function elephant -d "Minimal CLI for Fedora LAMP stack and VirtualHosts"
    set -l SUBCOMMAND help

    if test (count $argv) -gt 0
        set SUBCOMMAND $argv[1]
    end

    switch $SUBCOMMAND
        case wake start up
            echo "waking the stack..."
            sudo systemctl start httpd mariadb php-fpm
            echo "stack is awake."

        case sleep stop down
            echo "putting the stack to sleep..."
            sudo systemctl stop httpd mariadb php-fpm
            echo "stack is asleep."

        case status check pulse
            echo "stack status:"
            echo "  apache:  " (systemctl is-active httpd)
            echo "  mariadb: " (systemctl is-active mariadb)
            echo "  php-fpm: " (systemctl is-active php-fpm)

        case link
            if test (count $argv) -lt 2; or test (count $argv) -gt 3
                echo "usage: elephant link <project_path> [domain_name]"
                return 1
            end

            set -l PROJECT_PATH (realpath -m -- $argv[2])
            set -l PROJECT_NAME (path basename "$PROJECT_PATH")

            if not test -d "$PROJECT_PATH"
                echo "error: project directory does not exist: $PROJECT_PATH"
                return 1
            end

            if test (count $argv) -eq 3
                set DOMAIN_NAME $argv[3]
            else
                set DOMAIN_NAME "$PROJECT_NAME.test"
            end

            set -l CONF_FILE "/etc/httpd/conf.d/$DOMAIN_NAME.conf"

            echo "linking $PROJECT_PATH to $DOMAIN_NAME..."

            sudo chcon -R -t httpd_sys_content_t "$PROJECT_PATH"

            set -l VHOST_CONTENT "<VirtualHost *:80>
    ServerName $DOMAIN_NAME
    DocumentRoot \"$PROJECT_PATH\"

    <Directory \"$PROJECT_PATH\">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>"

            echo "$VHOST_CONTENT" \
                | sudo tee "$CONF_FILE" > /dev/null

            if not grep -q "$DOMAIN_NAME" /etc/hosts
                echo "127.0.0.1   $DOMAIN_NAME" \
                    | sudo tee -a /etc/hosts > /dev/null
            end

            sudo systemctl restart httpd
            echo "link established at http://$DOMAIN_NAME"

        case unlink
            if test (count $argv) -ne 2
                echo "usage: elephant unlink <domain_or_project_name>"
                return 1
            end

            if string match -q "*.*" -- $argv[2]
                set DOMAIN_NAME $argv[2]
            else
                set DOMAIN_NAME "$argv[2].test"
            end

            set -l CONF_FILE "/etc/httpd/conf.d/$DOMAIN_NAME.conf"

            echo "unlinking $DOMAIN_NAME..."

            if test -f "$CONF_FILE"
                sudo rm -- "$CONF_FILE"
            end

            sudo sed -i \
                "/127.0.0.1[[:space:]]*$DOMAIN_NAME/d" \
                /etc/hosts

            sudo systemctl restart httpd
            echo "link removed. project files were kept intact."

        case '*'
            echo "minimal LAMP manager for fedora"
            echo "usage: elephant <command>"
            echo ""
            echo "commands:"
            echo "  wake    - start apache, mariadb, and php-fpm"
            echo "  sleep   - stop the stack services"
            echo "  status  - check if services are running"
            echo "  link    - connect a project path to a local domain"
            echo "  unlink  - remove a domain routing configuration"
            echo ""
            echo "examples:"
            echo "  elephant link ."
            echo "  elephant link ./example-app"
            echo "  elephant link ~/Code/example-app example.local"
            echo "  elephant unlink example-app"
            echo "  elephant unlink example.local"
    end
end
