renew-certificate:
	docker compose run --rm  certbot certonly --webroot --webroot-path /var/www/certbot/ --dry-run -d prazskekontejnery.cz

copy-contents-to-server:
	rsync -avP --exclude 'Explorations' --exclude 'fe/node_modules' --exclude 'fe/.next/' --exclude 'fe/.git/'  ./Bachelor-thesis/* jakub@139.59.156.85:~/praguecontainers