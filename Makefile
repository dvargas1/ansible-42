DOMAIN       ?= localhost
SRCS_DIR     := inception/srcs
CERT_DIR     := $(SRCS_DIR)/requirements/nginx/conf
ANSIBLE_DIR  := ansible

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

# ──────────────── Deploy (Ansible) ────────────────

deploy:
	cd $(ANSIBLE_DIR) && ansible-playbook -i inventory.yaml full-setup.yaml

teardown:
	cd $(ANSIBLE_DIR) && ansible-playbook -i inventory.yaml full-teardown.yaml

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

.PHONY: up up-d down clean deploy teardown
