#import "@preview/touying:0.6.1": *
#import "@preview/numbly:0.1.0": numbly
#import "vorlage/hs-anhalt.typ": *

#set text(lang: "de")

#show: hsa-theme.with(
  aspect-ratio: "16-9",
  header: [Fachbereich],
  footer: [Name, Anlass],
  config-info(
    author: ("Autor 1", "Autor 2"),
    title: [Vorlage],
  ),
  config-common(handout: false),
)

#set heading(numbering: numbly("{1}.", default: "1.1"))

// Titelfolie erzeugen
#title-slide()

// Inhaltsverzeichnis
#heading([Inhalt], depth: 1, outlined: false, numbering: none)
#components.adaptive-columns(outline(indent: 1em, title: none))

= Einführung

Diese Vorlage verwendet #link("https://touying-typ.github.io/docs/intro", [Touying]) zur *Formatierung*.

= Spalten
#grid(
  columns: (1fr, 1fr),
  [Linke Seite], [Rechte Seite],
)

= Code

#raw(
  lang: "rust",
  block: true,
  `pub fn main() {
  println!("Hello, world!");
}`.text,
)

= Animationen
== `Pause`
First #pause Second

#pause

Third

== `meanwhile`
First

#pause

Second

#meanwhile

Third

#pause

Fourth

== weitere
Fortgeschrittenere Animationen gibt es in der #link("https://touying-typ.github.io/docs/dynamic/complex", [Touying Dokumentation])
