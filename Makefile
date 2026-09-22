# Baut PDFs aus den Markdown-Dokumenten in docs/.
#
# Nutzung:
#   make                 # alle Dokumente mit WeasyPrint bauen (Standard)
#   make ENGINE=latex    # alle Dokumente mit LaTeX (XeLaTeX) bauen
#   make satzung         # nur ein einzelnes Dokument bauen
#   make clean           # dist/ leeren

ENGINE ?= weasyprint

BREW_PREFIX := $(shell brew --prefix 2>/dev/null)
WEASYPRINT_ENV :=
ifneq ($(wildcard $(BREW_PREFIX)/lib/libgobject-2.0*.dylib),)
WEASYPRINT_ENV = DYLD_LIBRARY_PATH=$(BREW_PREFIX)/lib
endif

DOCS := satzung datenschutzkonzept paedagogisches-konzept
PDFS := $(addprefix dist/,$(addsuffix .pdf,$(DOCS)))

# Versionsangabe aus Git (Tag, sonst Kurz-Hash + "-dirty" bei Änderungen)
GIT_VERSION := $(shell git describe --tags --always --dirty 2>/dev/null || echo "kein-git")
BUILD_DATE := $(shell date +%Y-%m-%d)

.PHONY: all clean $(DOCS)

all: $(PDFS)

$(DOCS): %: dist/%.pdf

dist:
	mkdir -p dist

# --- WeasyPrint-Pfad (Markdown -> HTML -> PDF, Gestaltung per CSS) ---
ifeq ($(ENGINE),weasyprint)

dist/%.pdf: docs/%.md templates/weasyprint/template.html templates/weasyprint/style.css | dist
	pandoc "$<" \
		--from markdown+smart \
		--to html5 \
		--standalone \
		--template templates/weasyprint/template.html \
		--css templates/weasyprint/style.css \
		--metadata git_version="$(GIT_VERSION)" \
		--metadata build_date="$(BUILD_DATE)" \
		--table-of-contents --toc-depth=2 \
		-o dist/$*.html
	$(WEASYPRINT_ENV) python3 -m weasyprint dist/$*.html "$@" --base-url .
	@rm -f dist/$*.html

endif

# --- LaTeX-Pfad (Markdown -> PDF via XeLaTeX, beste Typografie) ---
ifeq ($(ENGINE),latex)

# Die Dokumentversion steht im YAML-Kopf jeder .md-Datei (version: ...).
# Pandoc interpoliert Variablen NICHT in --include-in-header-Dateien,
# darum wird hier eine kleine vars.tex mit den Werten für dieses
# Dokument erzeugt und zusätzlich eingebunden.
DOC_VERSION = $(shell awk -F': *' '/^version:/{gsub(/"/,"",$$2); print $$2; exit}' docs/$*.md)

dist/%.pdf: docs/%.md templates/latex/header.tex | dist
	printf '\\newcommand{\\gitversion}{%s}\n\\newcommand{\\docversion}{%s}\n' \
		"$(GIT_VERSION)" "$(DOC_VERSION)" > dist/$*-vars.tex
	pandoc "$<" \
		--from markdown+smart \
		--to pdf \
		--pdf-engine=xelatex \
		--include-in-header dist/$*-vars.tex \
		--include-in-header templates/latex/header.tex \
		--table-of-contents --toc-depth=2 \
		-o "$@"
	@rm -f dist/$*-vars.tex

endif

clean:
	rm -rf dist/*.pdf dist/*.html
