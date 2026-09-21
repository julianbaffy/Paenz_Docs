# Vereinsdokumente

Satzung, Datenschutzkonzept und Pädagogisches Konzept als Markdown,
versioniert mit Git, generiert als PDF mit [Pandoc](https://pandoc.org/).

## Struktur

```
docs/                        Markdown-Quelldateien (eine Datei je Dokument)
templates/weasyprint/        HTML-Vorlage + CSS für den WeasyPrint-Weg
templates/latex/             LaTeX-Header für den LaTeX-Weg
dist/                        generierte PDFs (nicht versioniert, siehe .gitignore)
.github/workflows/           GitHub Actions: baut PDFs automatisch
```

## Voraussetzungen (lokal)

- [Pandoc](https://pandoc.org/installing.html)
- Für den WeasyPrint-Weg: `pip install --break-system-packages weasyprint`
- Für den LaTeX-Weg: eine LaTeX-Distribution mit XeLaTeX, z. B.
  `sudo apt install texlive-xetex texlive-latex-extra texlive-fonts-extra fonts-noto`
  (unter macOS: [MacTeX](https://www.tug.org/mactex/))

## PDFs bauen

```bash
make                   # alle Dokumente, WeasyPrint (Standard)
make ENGINE=latex      # alle Dokumente, LaTeX/XeLaTeX
make satzung           # nur die Satzung
make clean             # dist/ leeren
```

Die PDFs landen in `dist/`.

## Welcher Weg für was?

- **WeasyPrint** (Markdown → HTML → PDF, Gestaltung per CSS in
  `templates/weasyprint/style.css`): einfacher anzupassen, wenn man CSS
  kennt; gute Kontrolle über Kopf-/Fußzeile, Titelseite, Tabellen, Farben.
  Das ist der Standardweg in diesem Repo.
- **LaTeX** (Markdown → PDF via XeLaTeX, Vorlage in
  `templates/latex/header.tex`): feinste Typografie (Silbentrennung,
  Satzspiegel), etwas mehr Einarbeitung, größere Installation.

Beide Wege erzeugen: Titelseite mit Vereinsname, Titel, Status
(z. B. „Entwurf"), Versionsnummer und Datum, Inhaltsverzeichnis,
durchnummerierte Überschriften bzw. Paragraphen, Kopfzeile mit
Dokumenttitel, Fußzeile mit Versionsnummer und Seitenzahl.

Farben und Schrift ändern:
WeasyPrint → `templates/weasyprint/style.css` (`--color-primary`),
LaTeX → `templates/latex/header.tex` (`\definecolor{vereinfarbe}{...}`).

Entwurf-Wasserzeichen aktivieren:
WeasyPrint → `body`-Element in `templates/weasyprint/template.html`
die Klasse `is-draft` ergänzen (oder per Pandoc-Filter aus dem
`status`-Feld ableiten).
LaTeX → die `draftwatermark`-Zeilen in `templates/latex/header.tex`
einkommentieren.

## Ein neues Dokument ergänzen

1. Neue Datei unter `docs/` anlegen, z. B. `docs/finanzordnung.md`, mit
   demselben YAML-Kopf wie die bestehenden Dokumente (`title`, `status`,
   `version`, `date`).
2. In `Makefile` den Dateinamen (ohne `.md`) zur Variable `DOCS` hinzufügen.
3. `make` ausführen.

## Versionierung und Beschlüsse

- Jede inhaltliche Änderung ist ein normaler Git-Commit; das `version`-Feld
  im YAML-Kopf des jeweiligen Dokuments von Hand hochzählen
  (z. B. `0.1.0` → `0.2.0`), damit sie auf dem PDF sichtbar ist.
- Für beschlossene Fassungen (z. B. nach einer Mitgliederversammlung) einen
  Git-Tag setzen, etwa:

  ```bash
  git tag -a satzung-2026-11-mv -m "Satzung, beschlossen MV 11/2026"
  git push --tags
  ```

- Ein GitHub-**Release** aus diesem Tag lässt die Workflow-Datei
  `.github/workflows/build-pdfs.yml` automatisch anspringen: Sie baut alle
  PDFs und hängt sie als Dateien an das Release an. So findet sich zu jeder
  beschlossenen Fassung ein fertiges PDF unter „Releases", ohne dass
  jemand lokal Pandoc installieren muss.
- Bei jedem Push auf `main` und bei jedem Pull Request werden die PDFs
  zusätzlich als Build-Artefakt bereitgestellt (Tab „Actions" → Workflow-Lauf
  → „Artifacts"), praktisch zum schnellen Gegenlesen von Änderungsvorschlägen.

## Änderungsvorschläge

Änderungen am besten über einen eigenen Branch und einen Pull Request
einreichen. GitHub zeigt dabei den reinen Text-Diff der Markdown-Datei an;
Vorstand oder Mitglieder können Zeilen direkt kommentieren, bevor der
Vorschlag in `main` übernommen wird.
