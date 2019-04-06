lets_encrypt_dns_conf_file=/config/dns-conf/cloudflare.ini

clean:
	docker-compose down --rmi all -v

init:
	# Install gems
	#docker-compose run --rm rails bundle install
	# Setup Terraform so it can run plans
	#docker-compose run --rm terraform init
	# Setup credentials for LetsEncrypt

plan: init
	docker-compose run --rm terraform plan

apply: init
	docker-compose run --rm terraform apply

destroy: init
	docker-compose run --rm terraform destroy

migrate:
	docker-compose run --rm rails bundle exec rake db:create db:migrate

start: init
	docker-compose up -d rails nginx postgres
	# Setup credentials for Let's Encrypt. We're cheating by relying on the
	# container having started up, but not having had enough time to
	# generate the certificate it will use.
	docker-compose exec nginx bash -c 'echo "dns_cloudflare_email = $${CLOUDFLARE_EMAIL}" > ${lets_encrypt_dns_conf_file}'
	docker-compose exec nginx bash -c 'echo "dns_cloudflare_api_key = $${CLOUDFLARE_TOKEN}" >> ${lets_encrypt_dns_conf_file}'

shell:
	docker-compose build --pull
	docker-compose run --rm rails bash
