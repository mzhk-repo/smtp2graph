PYTHON ?= python3
VENV_DIR ?= .venv
PRE_COMMIT ?= $(VENV_DIR)/bin/pre-commit

export PRE_COMMIT_HOME := $(CURDIR)/.cache/pre-commit

.PHONY: bootstrap validate

bootstrap:
	$(PYTHON) -m venv "$(VENV_DIR)"
	"$(VENV_DIR)/bin/python" -m pip install --disable-pip-version-check --requirement requirements-dev.txt
	"$(PRE_COMMIT)" install-hooks

validate:
	PRE_COMMIT_BIN="$(CURDIR)/$(PRE_COMMIT)" ./scripts/validate.sh
