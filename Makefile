# Findet alle .md-Dateien in docs/, auch in Unterordnern,
# und spiegelt die Ordnerstruktur nach dist/.
DOCS := $(patsubst docs/%.md,%,$(shell find docs -name '*.md'))
PDFS := $(addprefix dist/,$(addsuffix .pdf,$(DOCS)))

GIT_VERSION := $(shell git describe --tags --always --dirty 2>/dev/null || echo "kein-git")
BUILD_DATE := $(shell date +%Y-%m-%d)

.PHONY: all clean $(DOCS)

all: $(PDFS)

$(DOCS): %: dist/%.pdf


DOC_VERSION = $(shell awk -F': *' '/^version:/{gsub(/"/,"",$$2); print $$2; exit}' docs/$*.md)
DOC_DRAFT = $(shell awk -F': *' '/^draft:/{gsub(/"/,"",$$2); print $$2; exit}' docs/$*.md)
DOC_FRONTPAGE = $(shell awk -F': *' '/^frontpage:/{print $$2; exit}' docs/$*.md)

dist/%.pdf: docs/%.md templates/latex/header.tex
	mkdir -p $(dir $@)
	printf '\\newcommand{\\gitversion}{%s}\n\\newcommand{\\docversion}{%s}\n%s\n' \
		"$(GIT_VERSION)" "$(DOC_VERSION)" \
		"$(if $(filter false,$(DOC_FRONTPAGE)),\renewcommand{\maketitle}{})" \
		> dist/$*-vars.tex
	@if [ "$(DOC_DRAFT)" = "true" ]; then \
		printf '\\usepackage[firstpage=false,color=red!20,scale=1,angle=45]{draftwatermark}\n\\SetWatermarkText{ENTWURF}\n' >> dist/$*-vars.tex; \
	fi
	pandoc "$<" \
		--from markdown+smart \
		--to pdf \
		--pdf-engine=xelatex \
		--include-in-header dist/$*-vars.tex \
		--include-in-header templates/latex/header.tex \
		$(if $(filter true,$(DOC_TOC)),--table-of-contents --toc-depth=3) \
		-o "$@"
	@rm -f dist/$*-vars.tex

clean:
	rm -rf dist