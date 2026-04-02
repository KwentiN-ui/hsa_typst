#import "@preview/touying:0.6.1": *

#let slide(title: auto, ..args) = touying-slide-wrapper(self => {
  if title != auto {
    self.store.title = title
  }

  // Linkfarbe setzen
  show link: set text(fill: rgb(255, 0, 0))

  // Header definieren
  let header(self) = {
    set align(top)
    v(0.3cm)
    show: pad.with(1cm)
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

      if levels.len() > 0 {
        v(-0.5cm)
        set text(fill: self.colors.neutral.lighten(50%), size: 12pt, weight: "regular")
        levels.join([ #sym.space #sym.dash.en #sym.space ])
        v(-0.8cm)
        linebreak()
      }
    }

    set text(fill: self.colors.neutral, size: 25pt, weight: "bold")
    utils.display-current-heading(depth: self.slide-level)
  }
  // Footer definieren
  let footer(self) = {
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
      self.store.datum,
      utils.call-or-display(self, self.store.footer),
      "Seite " + context utils.slide-counter.display(),
    )
  }
  self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      footer: footer,
    ),
  )
  touying-slide(self: self, ..args)
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
      #set text(fill: self.colors.primary, size: 12pt, font: "Arial")
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

// TODO: Title-slide für Zwischenabschnitte erstellen

#let hsa-theme(
  aspect-ratio: "16-9",
  header: [Funktion, Fachbereich, Struktureinheit oder Name],
  footer: [Name, Anlass],
  datum: [#datetime.today().display("[day].[month].[year]")],
  ..args,
  body,
) = {
  set text(size: 20pt, font: "Montserrat")

  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      margin: (
        top: 4cm, // Platz für den Header
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
}
