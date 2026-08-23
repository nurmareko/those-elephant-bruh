function elephant -d "Minimal CLI for Fedora LAMP stack and VirtualHosts"
    set SUBCOMMAND $argv[1]
    
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
                echo "usage: elephant link <folder_name> [domain_name]"
                return 1
            end

            set FOLDER_NAME $argv[2]
            if test (count $argv) -eq 3
                set DOMAIN_NAME $argv[3]
            else
                set DOMAIN_NAME "$FOLDER_NAME.test"
            end
            
            set BASE_DIR "$HOME/Projects"
            set PROJECT_PATH "$BASE_DIR/$FOLDER_NAME"
            set CONF_FILE "/etc/httpd/conf.d/$DOMAIN_NAME.conf"

            echo "linking $DOMAIN_NAME..."

            if not test -d $PROJECT_PATH
                mkdir -p $PROJECT_PATH
                echo "<?php echo '<h1>$DOMAIN_NAME is live.</h1>'; ?>" > $PROJECT_PATH/index.php
                echo "created directory at $PROJECT_PATH"
            end

            sudo chcon -R -t httpd_sys_content_t $PROJECT_PATH
            
            set VHOST_CONTENT "<VirtualHost *:80>
    ServerName $DOMAIN_NAME
    DocumentRoot $PROJECT_PATH
    
    <Directory $PROJECT_PATH>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>"

            echo $VHOST_CONTENT | sudo tee $CONF_FILE > /dev/null
            
            if not grep -q "$DOMAIN_NAME" /etc/hosts
                echo "127.0.0.1   $DOMAIN_NAME" | sudo tee -a /etc/hosts > /dev/null
            end

            sudo systemctl restart httpd
            echo "link established at http://$DOMAIN_NAME"

        case unlink
            if test (count $argv) -ne 2
                echo "usage: elephant unlink <domain_or_folder_name>"
                return 1
            end

            if string match -q "*.*" -- $argv[2]
                set DOMAIN_NAME $argv[2]
            else
                set DOMAIN_NAME "$argv[2].test"
            end

            set CONF_FILE "/etc/httpd/conf.d/$DOMAIN_NAME.conf"

            echo "unlinking $DOMAIN_NAME..."

            if test -f $CONF_FILE
                sudo rm $CONF_FILE
            end

            sudo sed -i "/127.0.0.1[[:space:]]*$DOMAIN_NAME/d" /etc/hosts
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
            echo "  link    - connect a project folder to a .test domain"
            echo "  unlink  - remove a domain routing configuration"
            echo ""
            echo "examples:"
            echo "  elephant link myapp          (creates myapp.test)"
            echo "  elephant unlink myapp        (removes myapp.test)"
    end
end
