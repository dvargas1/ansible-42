DOMAIN       ?= localhost
SRCS_DIR     := inception/srcs
CERT_DIR     := $(SRCS_DIR)/requirements/nginx/conf
ANSIBLE_DIR  := ansible
TF_DIR       := terraform

NGINX_CONF   := $(CERT_DIR)/nginx.conf
WP_SETUP     := $(SRCS_DIR)/requirements/wordpress/tools/setup.sh
ENV_FILE     := $(SRCS_DIR)/.env
SSL_KEY      := $(CERT_DIR)/nginx.key
SSL_CRT      := $(CERT_DIR)/nginx.crt

# ──────────────── Local ────────────────

up: $(ENV_FILE) $(NGINX_CONF) $(WP_SETUP) $(SSL_KEY)
	cd $(SRCS_DIR) && docker compose up --build

up-d: $(ENV_FILE) $(NGINX_CONF) $(WP_SETUP) $(SSL_KEY)
	cd $(SRCS_DIR) && docker compose up --build -d

down:
	cd $(SRCS_DIR) && docker compose down

clean: down
	cd $(SRCS_DIR) && docker compose down -v --rmi local
	rm -f $(NGINX_CONF) $(WP_SETUP) $(SSL_KEY) $(SSL_CRT) $(CERT_DIR)/nginx.csr $(ENV_FILE)

# ──────────────── Deploy (Ansible only) ────────────────

deploy:
	cd $(ANSIBLE_DIR) && ansible-playbook -i inventory.yaml full-setup.yaml

teardown:
	cd $(ANSIBLE_DIR) && ansible-playbook -i inventory.yaml full-teardown.yaml

# ──────────────── Cloud Deploy (Terraform + Ansible) ────────────────

tf-init:
	cd $(TF_DIR) && terraform init

tf-plan:
	cd $(TF_DIR) && terraform plan

tf-apply:
	cd $(TF_DIR) && terraform apply

tf-destroy:
	cd $(TF_DIR) && terraform destroy

tf-output:
	@cd $(TF_DIR) && terraform output

# Full cloud deployment: create VM + deploy stack
cloud-deploy: tf-init
	cd $(TF_DIR) && terraform apply -auto-approve
	@echo ""
	@echo "Waiting 120s for VM to be ready..."
	@sleep 120
	cd $(ANSIBLE_DIR) && ansible-playbook -i inventory.yaml full-setup.yaml
	@echo ""
	@echo "========================================"
	@echo "Deployment complete!"
	@cd $(TF_DIR) && terraform output

# Full cloud teardown: remove stack + destroy VM
cloud-destroy:
	-cd $(ANSIBLE_DIR) && ansible-playbook -i inventory.yaml full-teardown.yaml
	cd $(TF_DIR) && terraform destroy -auto-approve

# ──────────────── Generated files ────────────────

$(ENV_FILE):
	cp $(SRCS_DIR)/example.env $(ENV_FILE)

$(NGINX_CONF): $(CERT_DIR)/nginx.conf.j2
	sed 's/{{ domain }}/$(DOMAIN)/g' $< > $@

$(WP_SETUP): $(SRCS_DIR)/requirements/wordpress/tools/setup.sh.j2
	sed 's/{{ domain }}/$(DOMAIN)/g' $< > $@
	chmod +x $@

$(SSL_KEY):
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout $(SSL_KEY) \
		-out $(SSL_CRT) \
		-subj "/CN=$(DOMAIN)" 2>/dev/null

.PHONY: up up-d down clean deploy teardown \
        tf-init tf-plan tf-apply tf-destroy tf-output \
        cloud-deploy cloud-destroy
