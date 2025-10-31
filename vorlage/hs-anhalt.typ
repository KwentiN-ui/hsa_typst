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
    set text(fill: self.colors.primary, size: 12pt, font: "Arial")
    [| #self.store.header]
    h(1fr)
    box(image("logo_full.svg", height: 1.5cm), baseline: 50%)
    linebreak()

    set text(fill: self.colors.neutral, size: 25pt, weight: "bold")
    utils.display-current-heading()
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
      columns: (1fr, 1fr, 1fr),
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
    pad(top: 4cm, bottom: 2cm, left: 1.5cm, right: 1.5cm)[
      #align(top + left)[
        #text(size: 2.2em, weight: "bold", fill: self.colors.neutral-light, info.title)
      ]
      #align(bottom + right)[
        // Autoren
        #set text(size: 1.5em, fill: self.colors.neutral-light)
        #stack(
          dir: ttb,
          spacing: 0.4em, // Vertikaler Abstand zwischen den Namen
          ..info.authors, // Fügt alle Autoren als einzelne Elemente hinzu
        )
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
