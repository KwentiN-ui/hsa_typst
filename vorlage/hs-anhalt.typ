#import "@preview/touying:0.7.0": *

#let hsa-header(self) = {
  set align(top)
  v(0.3cm)
  show: pad.with(x: 1cm, top: 1cm, bottom: 0cm)
  set align(horizon)
  set text(fill: self.colors.primary, size: 12pt, font: "Montserrat")
  [| #self.store.header]
  h(1fr)
  box(image("logo_full.svg", height: 1.5cm), baseline: 50%)
  linebreak()

  // Breadcrumbs (übergeordnete Kapitel)
  context {
    let current-page = here().page()
    let hs = query(selector(heading))
    let hs-before = hs.filter(h => h.location().page() <= current-page)

    let slide-headings = hs-before.filter(h => h.level <= self.slide-level)
    let slide-heading = if slide-headings.len() > 0 { slide-headings.last() } else { none }

    let levels = ()
    if slide-heading != none {
      let current-level = slide-heading.level
      let found-slide-heading = false

      for h in hs-before.rev() {
        if not found-slide-heading {
          if h.location() == slide-heading.location() {
            found-slide-heading = true
          }
          continue
        }

        if h.level < current-level {
          levels.insert(0, h.body)
          current-level = h.level
        }
        if current-level <= 1 {
          break
        }
      }
    }

    let breadcrumbs = if levels.len() > 0 {
      set text(fill: self.colors.neutral.lighten(50%), size: 12pt, weight: "regular")
      levels.join([ #sym.space #sym.dash.en #sym.space ])
    } else {
      hide[A]
    }
    v(-0.5cm)
    breadcrumbs
    v(-0.8cm)
    linebreak()
  }

  set text(fill: self.colors.neutral, size: 25pt, weight: "bold")
  context {
    if self.store.title != none {
      self.store.title
    } else {
      utils.display-current-heading(depth: self.slide-level)
    }
  }
}

#let hsa-footer(self) = {
  set align(alignment.horizon)
  show: components.cell.with(fill: gradient.linear(
    self.colors.secondary,
    self.colors.secondary,
    self.colors.primary,
    angle: 5deg,
  ))
  show: pad.with(x: 1cm)
  set text(fill: self.colors.neutral-light, size: 12pt)
  grid(
    columns: (1fr, 4fr, 1fr),
    align: (left, center, right),
    self.store.datum, utils.call-or-display(self, self.store.footer), "Seite " + context utils.slide-counter.display(),
  )
}

#let slide(title: auto, ..args) = touying-slide-wrapper(self => {
  let args-named = args.named()
  // Titel extrahieren und im Store speichern, falls vorhanden
  let actual-title = if title != auto { title } else { args-named.at("title", default: none) }

  if actual-title != none {
    self.store.title = actual-title
  } else {
    self.store.title = none
  }

  // Titel aus den named args entfernen, damit touying-slide ihn nicht im Body rendert
  let named = (:)
  for (k, v) in args.named() {
    if k != "title" {
      named.insert(k, v)
    }
  }

  // Linkfarbe setzen
  show link: set text(fill: rgb(255, 0, 0))

  self = utils.merge-dicts(
    self,
    config-page(
      header: hsa-header,
      footer: hsa-footer,
    ),
  )
  touying-slide(self: self, ..named, ..args.pos())
})

#let title-slide(
  config: (:),
  extra: none,
  ..args,
) = touying-slide-wrapper(self => {
  // Title Header
  let title-header(self) = {
    set align(top)
    rect(width: 100%, fill: self.colors.neutral-light)[
      #v(0.3cm)
      #show: pad.with(left: 1cm, right: 1cm)
      #set align(horizon)
      #set text(fill: self.colors.primary, size: 12pt, font: "Montserrat")
      | #self.store.header
      #h(1fr)
      #box(image("logo_full.svg", height: 1.5cm), baseline: 50%)
      #v(.4cm)
    ]
  }

  let title-background(self) = {
    rect(
      width: 100%,
      height: 100%,
      fill: gradient.linear(
        self.colors.secondary, // Rot
        self.colors.primary, // Blau
        angle: 55deg,
      ),
    )
  }

  self = utils.merge-dicts(
    self,
    config,
    config-common(freeze-slide-counter: true),
    config-page(
      background: title-background(self),
      header: title-header(self),
      footer: none,
    ),
  )

  let info = self.info + args.named()
  info.authors = {
    let authors = if "authors" in info { info.authors } else { info.author }
    if type(authors) == array { authors } else { (authors,) }
  }

  let body(self) = {
    pad(top: 1.5cm, bottom: 1cm, left: 1.5cm, right: 1.5cm)[
      #box(width: 100%, height: 100%)[
        #place(top + left)[
          #text(size: 2.5em, weight: "bold", fill: self.colors.neutral-light, info.title)
          #if info.subtitle != none {
            linebreak()
            v(0.2cm)
            text(size: 1.5em, weight: "regular", fill: self.colors.neutral-light, info.subtitle)
          }
        ]
        #place(bottom + right)[
          // Autoren
          #set text(size: 1.2em, fill: self.colors.neutral-light)
          #stack(
            dir: ttb,
            spacing: 0.3em, // Vertikaler Abstand zwischen den Namen
            ..info.authors, // Fügt alle Autoren als einzelne Elemente hinzu
          )
        ]
      ]
    ]
  }

  touying-slide(self: self, body(self))
})

#let cited-on-page = state("cited-on-page", (:))

#let hsa-theme(
  aspect-ratio: "16-9",
  header: [Funktion, Fachbereich, Struktureinheit oder Name],
  footer: [Name, Anlass],
  datum: [#datetime.today().display("[day].[month].[year]")],
  bibliographie_path: "../bibliographie.bib",
  ..args,
  body,
) = {
  set text(size: 18pt, font: "Montserrat", lang: "de")
  show figure.caption: set text(size: 14pt)
  set figure(numbering: none)

  // Code
  show raw: set text(font: "JetBrains Mono")

  show raw.where(block: true): it => block(
    fill: rgb("#f5f3fc"), // Ganz leichtes Grau als Hintergrund
    inset: (left: 10pt, y: 8pt, right: 8pt), // Innenabstand
    radius: (left: 0pt, right: 3pt), // Nur rechts abgerundet
    stroke: (left: 1.5pt + rgb("#2B347A")),
    width: 100%,
    it,
  )

  show footnote.entry: set text(size: 10pt)

  // Custom cite rule for consistent global numbering and footnotes on every slide
  show cite.where(form: "normal"): it => {
    if not it.has("key") { return it }
    context {
      let page-id = str(here().page())
      let key = str(it.key)
      let cited = cited-on-page.get()
      let slide-citations = cited.at(page-id, default: ())
      if not slide-citations.contains(key) {
        // Nur die Fußnote zurückgeben. Der Marker ist standardmäßig hochgestellt/klein.
        footnote(numbering: _ => it)[
          #show regex("^\[\d+\]\s"): none
          #cite(it.key, form: "full")
        ]
        cited-on-page.update(c => {
          let l = c.at(page-id, default: ())
          l.push(key)
          c.insert(page-id, l)
          c
        })
      } else {
        // Folgevorkommen auf derselben Folie ebenfalls klein/hochgestellt
        super(it)
      }
    }
  }

  // Fußnoten-Einträge im Footer für bessere Ausrichtung anpassen
  show footnote.entry: it => {
    let loc = it.note.location()
    context {
      let num = numbering(it.note.numbering, ..counter(footnote).at(loc))
      grid(
        columns: (2.5em, 1fr),
        column-gutter: 0.2em,
        num, it.note.body,
      )
    }
  }

  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      margin: (
        top: 4.5cm, // Platz für den Header
        bottom: 1.2cm, // Platz für den Footer
        left: 1cm, // Horizontaler Rand
        right: 1cm, // Horizontaler Rand
      ),
    ),
    config-common(
      slide-fn: slide,
      slide-level: 4,
    ),
    config-colors(
      primary: rgb("#13017C"),
      secondary: rgb("#D40009"),
      neutral: black,
      neutral-light: white,
    ),
    config-methods(alert: utils.alert-with-primary-color),
    config-store(
      title: none,
      footer: footer,
      header: header,
      datum: datum,
    ),
    ..args,
  )

  body

  if bibliographie_path != none {
    // Bibliographie-Folie mit Titel für den Header
    slide(title: [Literatur])[
      #hide(heading(level: 1, numbering: none, outlined: false)[Literatur])
      #set text(size: 12pt)
      #bibliography(bibliographie_path, title: none, style: "ieee")
    ]
  }
}
