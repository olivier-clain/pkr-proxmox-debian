# Makefile for Packer Debian 13 Template
# Automates common build tasks

.PHONY: help init validate fmt build clean check all

# Variables
PACKER := packer
ENV_FILE := .env

# Colors for display
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

help: ## Display this help
	@echo "$(GREEN)Packer Debian 13 - Available commands:$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(GREEN)Prerequisites:$(NC)"
	@echo "  - Packer >= 1.9.0 installed"
	@echo "  - .env file configured with your credentials"
	@echo ""

init: ## Initialize Packer and download plugins
	@echo "$(GREEN)Initializing Packer...$(NC)"
	@$(PACKER) init .
	@echo "$(GREEN)✓ Plugins installed$(NC)"

validate: check-env ## Validate Packer configuration
	@echo "$(GREEN)Validating configuration...$(NC)"
	@. ./$(ENV_FILE) && $(PACKER) validate .
	@echo "$(GREEN)✓ Configuration valid$(NC)"

fmt: ## Format HCL files
	@echo "$(GREEN)Formatting HCL files...$(NC)"
	@$(PACKER) fmt .
	@echo "$(GREEN)✓ Files formatted$(NC)"

check: check-env fmt validate ## Check everything (format + validation)
	@echo "$(GREEN)✓ All checks are OK$(NC)"

build: check-env validate ## Build template on single hypervisor (default mode)
	@echo "$(GREEN)Starting build on single hypervisor...$(NC)"
	@echo "$(YELLOW)This may take 10-20 minutes...$(NC)"
	@. ./$(ENV_FILE) && $(PACKER) build debian-13.pkr.hcl
	@echo "$(GREEN)✓ Build completed successfully$(NC)"

build-multi: check-env validate ## Build template on all 3 hypervisors in parallel
	@echo "$(GREEN)Starting parallel build on 3 hypervisors...$(NC)"
	@echo "$(CYAN)Hypervisors: 10.0.0.240, 10.0.0.235, 10.0.0.245$(NC)"
	@echo "$(YELLOW)This may take 10-20 minutes...$(NC)"
	@cd multi && . ../.env && $(PACKER) build .
	@echo "$(GREEN)✓ All templates created successfully$(NC)"

build-hv1: check-env validate ## Build template on Hypervisor 1 only (10.0.0.240)
	@echo "$(GREEN)Building on Hypervisor 1 (10.0.0.240)...$(NC)"
	@cd multi && . ../.env && $(PACKER) build -only='proxmox-iso.debian-hv1' .
	@echo "$(GREEN)✓ Template created on HV1$(NC)"

build-hv2: check-env validate ## Build template on Hypervisor 2 only (10.0.0.235)
	@echo "$(GREEN)Building on Hypervisor 2 (10.0.0.235)...$(NC)"
	@cd multi && . ../.env && $(PACKER) build -only='proxmox-iso.debian-hv2' .
	@echo "$(GREEN)✓ Template created on HV2$(NC)"

build-hv3: check-env validate ## Build template on Hypervisor 3 only (10.0.0.245)
	@echo "$(GREEN)Building on Hypervisor 3 (10.0.0.245)...$(NC)"
	@cd multi && . ../.env && $(PACKER) build -only='proxmox-iso.debian-hv3' .
	@echo "$(GREEN)✓ Template created on HV3$(NC)"

build-force: check-env ## Build template without prior validation
	@echo "$(YELLOW)Forced build (without validation)...$(NC)"
	@. ./$(ENV_FILE) && $(PACKER) build -force .

build-debug: check-env ## Build with detailed logs for debugging
	@echo "$(GREEN)Build in debug mode...$(NC)"
	@. ./$(ENV_FILE) && PACKER_LOG=1 $(PACKER) build -debug .

clean: ## Clean temporary files and cache
	@echo "$(GREEN)Cleaning...$(NC)"
	@rm -rf packer_cache/
	@rm -f crash.log
	@rm -f packer-manifest.json
	@rm -f *.log
	@echo "$(GREEN)✓ Cleanup completed$(NC)"

clean-all: clean ## Clean everything (cache + plugins)
	@echo "$(YELLOW)Complete cleanup (plugins included)...$(NC)"
	@rm -rf .packer.d/
	@echo "$(GREEN)✓ Complete cleanup finished$(NC)"

check-env: ## Verify that the .env file exists
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "$(RED)✗ Error: The .env file doesn't exist$(NC)"; \
		echo "$(YELLOW)→ Copy .env.example to .env and configure your credentials$(NC)"; \
		echo "  cp .env.example .env"; \
		exit 1; \
	fi
	@echo "$(GREEN)✓ .env file found$(NC)"

check-vars: check-env ## Verify that environment variables are defined
	@echo "$(GREEN)Verifying variables...$(NC)"
	@. ./$(ENV_FILE) && \
	if [ -z "$$PKR_VAR_proxmox_api_url" ]; then \
		echo "$(RED)✗ PKR_VAR_proxmox_api_url not defined$(NC)"; exit 1; \
	fi && \
	if [ -z "$$PKR_VAR_proxmox_api_token_id" ]; then \
		echo "$(RED)✗ PKR_VAR_proxmox_api_token_id not defined$(NC)"; exit 1; \
	fi && \
	if [ -z "$$PKR_VAR_proxmox_api_token_secret" ]; then \
		echo "$(RED)✗ PKR_VAR_proxmox_api_token_secret not defined$(NC)"; exit 1; \
	fi && \
	if [ -z "$$PKR_VAR_proxmox_node" ]; then \
		echo "$(RED)✗ PKR_VAR_proxmox_node not defined$(NC)"; exit 1; \
	fi && \
	if [ -z "$$PKR_VAR_ssh_password" ]; then \
		echo "$(RED)✗ PKR_VAR_ssh_password not defined$(NC)"; exit 1; \
	fi
	@echo "$(GREEN)✓ All required variables are defined$(NC)"

inspect: ## Inspect Packer configuration
	@echo "$(GREEN)Inspecting configuration...$(NC)"
	@$(PACKER) inspect .

version: ## Display Packer version
	@$(PACKER) version

all: init check build ## Complete workflow: init + check + build

setup: ## Initial project setup (first use)
	@echo "$(GREEN)Initial project configuration...$(NC)"
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "$(YELLOW)Creating .env file from .env.example...$(NC)"; \
		cp .env.example $(ENV_FILE); \
		echo "$(YELLOW)⚠ Edit the .env file with your credentials before continuing$(NC)"; \
	else \
		echo "$(GREEN)✓ .env file already exists$(NC)"; \
	fi
	@$(MAKE) init
	@echo ""
	@echo "$(GREEN)✓ Initial configuration completed$(NC)"
	@echo "$(YELLOW)→ Next step: Edit .env then run 'make build'$(NC)"

.DEFAULT_GOAL := help
