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

- eine LaTeX-Distribution mit XeLaTeX
  `sudo apt install texlive-xetex texlive-latex-extra texlive-fonts-extra fonts-noto`
  (unter macOS: [MacTeX](https://www.tug.org/mactex/))

## PDFs bauen

```bash
make                   # alle Dokumente, LaTex (Standard)
make satzung           # nur die Satzung
make clean             # dist/ löschen (wird bei make neu erstellt)
```

Die PDFs landen in `dist/`. Unterordner in `/docs` werden auch in `/dist`erstellt. 

## YAML Struktur

```m
---
title: "Datenschutzkonzept"
subtitle: "Muster e. V."
status: "Entwurf"
version: "0.1.0"
date: "2026-09-21"
lang: de
toc: true
frontpage: true
draft: false
---
```

Titelseite (wenn title: true), Status (z. B. „Entwurf"), Versionsnummer und Datum, Inhaltsverzeichnis (wenn toc: true),
durchnummerierte Überschriften bzw. Paragraphen, Kopfzeile mit
Dokumenttitel, Fußzeile mit Versionsnummer und Seitenzahl.

Farben und Schrift ändern:
`templates/latex/header.tex` (`\definecolor{vereinfarbe}{...}`).

## Ein neues Dokument ergänzen

1. Neue Datei unter `docs/` anlegen, z. B. `docs/finanzordnung.md`, mit
   demselben YAML-Kopf wie die bestehenden Dokumente (s. o.).
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

# To Do

- Anlagen zu Datenschutzkonzept mit Eingabefeldern?
- Aktuelle Dateien als MD einpflegen. Bisher nur Plazhalter, außer Pädagorisches Konzept.