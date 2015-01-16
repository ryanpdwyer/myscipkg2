# Makefile for myscipkg2
PKG_NAME=myscipkg2
PKG_DIR=myscipkg2

VERSION := $(shell python setup.py --version)

help:
	@echo "clean-build	remove build artifacts"
	@echo "clean-pyc	remove Python file artifacts"
	@echo "lint			check style with flake8"
	@echo "test 		run tests quickly with the default Python"
	@echo "coverage		check code coverage quickly with the default Python"
	@echo "docs			generate Sphinx HTML documentation, including API docs"
	@echo "release		package and upload a release"
	@echo "sdist		package"

clean: clean-build clean-pyc

clean-build:
	rm -fr build/
	rm -fr dist/
	rm -fr *.egg-info

clean-pyc:
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +

lint:
	flake8 myscipkg2 test

test:
	python setup.py test

coverage:
	coverage run --source $(PKD_DIR) setup.py test
	coverage report -m
	coverage html
	open htmlcov/index.html

docs:
	$(MAKE) -C docs clean
	$(MAKE) -C docs html
	open docs/_build/html/index.html

release: clean test check-version
	python setup.py sdist bdist_wheel
	twine upload dist/*

# Check version string for PEP440 compatibility
# The regular expression used to do the check is taken from pip
# See https://github.com/pypa/pip/search?utf8=✓&q=pep440
PEP440=$(shell [[ $(VERSION) =~ ^v?(\d+)((a|b|c|rc)(\d+))?$$ ]] && echo "yes" || echo "no")
ifeq (no,$(PEP440))
check-version:
	$(error "Not a valid PEP440 version ($(VERSION)). Run git tag and try again.")
else
check-version:
	@echo "Version okay."
endif

# Helper if you need to figure out what packages are being imported
# Useful if Read the Docs is failing and you need to mock out more dependencies
find-imports:
	find $(PKG_DIR) -name "*.py" -exec fgrep "import" {} \; |  egrep '^(\s*)(import|from)' | sed 's/^\s+//' | tr -s ' ' | cut -d " " -f 2 | fgrep -v $(PKG_NAME) | sort -u | uniq

.PHONY: help clean clean-pyc clean-build list test coverage docs release sdist
