lets_encrypt_dns_conf_file=/config/dns-conf/cloudflare.ini

clean:
	docker-compose down --rmi all -v

init:
	docker-compose build --pull ansible terraform
	# Setup Terraform so it can run plans. Run via `sh -c` so the
	# container's environment variables can be referenced.
	docker-compose run --rm --entrypoint="" \
		terraform sh -c 'terraform init \
		--backend-config="hostname=$${TFE_HOSTNAME}" \
		--backend-config="token=$${TFE_TOKEN}" \
		--backend-config="organization=$${TFE_ORGANIZATION}" \
		--backend-config="workspaces=[{name=\"$${TFE_WORKSPACE}\"}]"'

plan: init
	docker-compose run --rm terraform plan

apply: init
	docker-compose run --rm terraform apply

destroy: init
	docker-compose run --rm terraform destroy

ssh:
	docker-compose run --rm --entrypoint="" terraform sh -c ./ssh.sh

migrate:
	docker-compose run --rm rails bundle exec rake db:create db:migrate

start: init
	# Install gems
	docker-compose run --rm rails bundle install
	# Start services
	docker-compose up -d rails nginx postgres
	# Setup credentials for Let's Encrypt. We're cheating by relying on the
	# container having started up, but not having had enough time to
	# generate the certificate it will use.
	docker-compose exec nginx bash -c 'echo "dns_cloudflare_email = $${CLOUDFLARE_EMAIL}" > ${lets_encrypt_dns_conf_file}'
	docker-compose exec nginx bash -c 'echo "dns_cloudflare_api_key = $${CLOUDFLARE_TOKEN}" >> ${lets_encrypt_dns_conf_file}'

shell:
	docker-compose build --pull
	docker-compose run --rm rails bash

ansible:
	docker-compose build --pull ansible

edit-secrets:
	docker-compose run --rm --entrypoint="" ansible ansible-vault edit --vault-password-file=vault-password vault

view-secrets:
	docker-compose run --rm --entrypoint="" ansible ansible-vault view --vault-password-file=vault-password vault
