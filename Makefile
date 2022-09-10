# vim: ts=2 sw=2 noet

SHELL := bash

.DEFAULT_GOAL := help

help:          ## Show this message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN { FS = ":.*?## " }; { printf "\033[36;1m%-20s\033[0m \033[37;1m%s\033[0m\n", $$1, $$2 }'

all: dotfiles  ## Install everything

dotfiles:      ## Install dotfiles
	@printf '\e[37;1mProcessing dotfiles\e[0m\n'
	@for file in $$(git ls-files '.*' | grep -vF -e / -e .gitignore); do \
	  printf '  >> \e[36mInstalling %-20s -> ~/%s \e[0m\n' "$$file" "$$file"; \
	  ln -sfn "$(CURDIR)/$$file" ~/; \
	done
	@printf '\e[37;1mProcessing .local\e[0m\n'
	@git ls-files '.local' | xargs dirname | awk '{ print "$(HOME)/" $$0 }' | xargs mkdir -p
	@for file in $$(git ls-files '.local'); do \
	  printf '  >> \e[36mInstalling %-30s -> ~/%s \e[0m\n' "$$file" "$$file"; \
	  ln -sfn "$(CURDIR)/$$file" ~/$$file; \
	done
