#import "@preview/touying:0.8.0": *

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

#let zwischentitel-slide(
  ..args,
) = touying-slide-wrapper(self => {
  let pos = args.pos()
  let named = args.named()
  let subtitle = named.at("subtitle", default: auto)
  let numbered = named.at("numbered", default: true)
  let title = named.at("title", default: auto)
  let blau = named.at("blau", default: true)
  let config = named.at("config", default: (:))

  // Positional argument if passed manually (and not none)
  if pos.len() > 0 and pos.first() != none and subtitle == auto {
    subtitle = pos.first()
  }

  // Heading check if called via Touying's new-section-slide-fn
  let current-heading = if "headings" in self and self.headings.len() > 0 {
    self.headings.last()
  } else {
    none
  }
  if current-heading != none {
    let outlined = current-heading.at("outlined", default: true)
    let numbering = current-heading.at("numbering", default: auto)
    if not outlined or numbering == none {
      return none
    }
  }

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
      fill: if blau == false { self.colors.secondary } else { self.colors.primary },
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

  let info = self.info + named
  info.authors = {
    let authors = if "authors" in info { info.authors } else { info.author }
    if type(authors) == array { authors } else { (authors,) }
  }

  let body(self) = {
    pad(top: 1.5cm, bottom: 1cm, left: 1.5cm, right: 1.5cm)[
      #box(width: 100%, height: 100%)[
        #place(top + left)[
          #text(size: 2.5em, weight: "bold", fill: self.colors.neutral-light)[
            #if title != auto {
              title
            } else {
              utils.display-current-heading(level: 1, numbered: numbered)
            }
          ]
          #context {
            let sub-content = if subtitle != auto {
              subtitle
            } else {
              let current-page = here().page()
              let all-headings = query(heading.where(outlined: true))
              let sections = all-headings.filter(h => h.level == 1)
              let current-section = sections.filter(h => h.location().page() <= current-page).at(-1, default: none)

              if current-section != none {
                let idx = all-headings.position(h => h.location() == current-section.location())
                if idx != none {
                  let subs = ()
                  let remaining = if idx + 1 < all-headings.len() { all-headings.slice(idx + 1) } else { () }
                  for h in remaining {
                    if h.level <= 1 {
                      break
                    }
                    if h.level == 2 {
                      subs.push(h.body)
                    }
                  }
                  if subs.len() > 0 {
                    if subs.len() > 5 {
                      let mid = calc.ceil(subs.len() / 2)
                      grid(
                        columns: (1fr, 1fr),
                        gutter: 1.5cm,
                        subs.slice(0, mid).join(linebreak()),
                        subs.slice(mid).join(linebreak()),
                      )
                    } else {
                      subs.join(linebreak())
                    }
                  }
                }
              }
            }
            if sub-content != none {
              linebreak()
              v(0.4cm)
              text(size: 1.5em, weight: "regular", fill: self.colors.neutral-light)[#sub-content]
            }
          }
        ]
      ]
    ]
  }

  touying-slide(self: self, body(self))
})


#let hsa-theme(
  aspect-ratio: "16-9",
  header: [Funktion, Fachbereich, Struktureinheit oder Name],
  footer: [Name, Anlass],
  datum: [#datetime.today().display("[day].[month].[year]")],
  bibliographie_path: "../zotero.bib",
  ..args,
  body,
) = {
  set text(size: 18pt, font: "Montserrat", lang: "de")
  show figure.caption: set text(size: 14pt)
  set figure(numbering: none)

  // Code
  // show raw: set text(font: "JetBrains Mono")

  show raw.where(block: true): it => block(
    fill: rgb("#f5f3fc"), // Ganz leichtes Grau als Hintergrund
    inset: (left: 10pt, y: 8pt, right: 8pt), // Innenabstand
    radius: (left: 0pt, right: 3pt), // Nur rechts abgerundet
    stroke: (left: 1.5pt + rgb("#2B347A")),
    width: 100%,
    it,
  )

  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      margin: (
        top: 3.8cm, // Platz für den Header
        bottom: 1.2cm, // Platz für den Footer
        left: 1cm, // Horizontaler Rand
        right: 1cm, // Horizontaler Rand
      ),
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: zwischentitel-slide,
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
