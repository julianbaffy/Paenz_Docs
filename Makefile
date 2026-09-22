# Findet alle .md-Dateien in docs/, auch in Unterordnern,
# und spiegelt die Ordnerstruktur nach dist/.
DOCS := $(patsubst docs/%.md,%,$(shell find docs -name '*.md'))
PDFS := $(addprefix dist/,$(addsuffix .pdf,$(DOCS)))

GIT_VERSION := $(shell git describe --tags --always --dirty 2>/dev/null || echo "kein-git")
BUILD_DATE := $(shell date +%Y-%m-%d)

ENGINE ?= latex

.PHONY: all clean $(DOCS)

all: $(PDFS)

$(DOCS): %: dist/%.pdf

# --- WeasyPrint-Pfad ---
ifeq ($(ENGINE),weasyprint)

dist/%.pdf: docs/%.md templates/weasyprint/template.html templates/weasyprint/style.css
	mkdir -p $(dir $@)
	pandoc "$<" \
		--from markdown+smart \
		--to html5 \
		--standalone \
		--template templates/weasyprint/template.html \
		--css templates/weasyprint/style.css \
		--metadata git_version="$(GIT_VERSION)" \
		--metadata build_date="$(BUILD_DATE)" \
		$(if $(filter true,$(DOC_TOC)),--table-of-contents --toc-depth=3) \
		-o dist/$*.html
	weasyprint dist/$*.html "$@" --base-url .
	@rm -f dist/$*.html

endif

# --- LaTeX-Pfad ---
ifeq ($(ENGINE),latex)

DOC_VERSION = $(shell awk -F': *' '/^version:/{gsub(/"/,"",$$2); print $$2; exit}' docs/$*.md)

dist/%.pdf: docs/%.md templates/latex/header.tex
	mkdir -p $(dir $@)
	printf '\\newcommand{\\gitversion}{%s}\n\\newcommand{\\docversion}{%s}\n' \
		"$(GIT_VERSION)" "$(DOC_VERSION)" > dist/$*-vars.tex
	pandoc "$<" \
		--from markdown+smart \
		--to pdf \
		--pdf-engine=xelatex \
		--include-in-header dist/$*-vars.tex \
		--include-in-header templates/latex/header.tex \
		$(if $(filter true,$(DOC_TOC)),--table-of-contents --toc-depth=3) \
		-o "$@"
	@rm -f dist/$*-vars.tex

endif

clean:
	rm -rf dist