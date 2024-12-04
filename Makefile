# vim: ts=2 sts=2 sw=2 noet ai

SHELL := bash

.DEFAULT_GOAL := help

help:          ## Show this message
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN { FS = ":.*?## " }; { lines[FNR]=$$1":##"$$2; len=length($$1); if (len > max) max=len; ++c; } END { FS=":##";fmt="\033[36;1m%-"max"s\033[37;1m    %s\033[0m\n"; for(i=1;i<=c;++i){$$0=lines[i]; printf(fmt, $$1, $$2) } }'

all: dotfiles gitconfig  ## Install everything

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

gitconfig:     ## builds gitconfig file
	bash build/git-config-build.sh
