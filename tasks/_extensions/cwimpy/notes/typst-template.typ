// Imports
#import "@preview/whalogen:0.2.0": ce
#import "@preview/codly:1.3.0": codly-init, codly
#import "@preview/codly-languages:0.1.8": codly-languages
#import "@preview/showybox:2.0.3": showybox
#import "@preview/ctheorems:1.1.3": thmenv, thmrules

// Date formatting helper
#let _notes-date-format = "[day padding:zero].[month].[year repr:full]"

#let _format-notes-date(d) = {
  if d == none or d == auto {
    return datetime.today()
  }
  if type(d) == datetime {
    return d
  }
  if type(d) == str {
    let m = d.match(regex("^(\d{4})-(\d{2})-(\d{2})$$"))
    if m != none {
      let (y, mo, day) = m.captures
      return datetime(year: int(y), month: int(mo), day: int(day))
    }
  }
  d
}

// Main template function
#let template(
  title: "Lecture Notes Title",
  short_title: none,
  description: none,
  date: none,
  authors: (),
  toc: false,
  lof: false,
  lot: false,
  lol: false,
  bibliography_file: none,
  bibstyle: "apa",
  paper_size: "a4",
  landscape: false,
  cols: 1,
  text_font: "Arial",
  code_font: "DejaVu Sans Mono",
  accent: "#DC143C",
  h1-prefix: "Lecture",
  colortab: false,
  body
) = {
  // Necessary for ctheorems package
  show: thmrules

  // Set accent color (passed as color object from typst-show.typ)
  let accent_color = accent

  // Construct string title
  let str_title = ""
  if type(title) == content and title.has("children") {
    for element in title.children {
      if element.has("text") {
        str_title = str_title + element.text + " " 
      }
    }
  } else if type(title) == str {
    str_title = title
  }
  str_title = str_title.trim(" ")

  // Set document metadata
  set document(title: str_title, author: authors.map(author => author.name))
  set text(font: text_font, size: 12pt)
  show raw: set text(font: code_font)

  // Style links
  show link: it => {
    let author_names = ()
    for author in authors {
      author_names.push(author.name)
    }
    if it.body.has("text") and it.body.text in author_names {
      it
    } else {
      underline(stroke: (dash: "densely-dotted"), offset: 2pt, text(fill: accent_color, it)) 
    }
  }

  // Configure page
  set page(
    paper: paper_size,
    margin: (x: 1.5cm, y: 2cm),
    columns: cols,
    flipped: landscape,
    numbering: "1",
    number-align: center,
    header: context {
      let elems = query(
        selector(heading.where(level: 1)).before(here())
      )
      
      let head_title = text(fill: accent_color, {
        if short_title != none { short_title } else { str_title }
      })
      
      if elems.len() == 0 {
        align(right, "")
      } else {
        let current_heading = elems.last()
        if current_heading.numbering != none {
          head_title + h(1fr) + emph(h1-prefix + " " + counter(heading.where(level: 1)).display("1: ") + current_heading.body)
        } else {
          head_title + h(1fr) + emph(current_heading.body)
        }
        v(-6pt)
        line(length: 100%, stroke: (thickness: 1pt, paint: accent_color, dash: "solid"))
      }
    },
    background: if colortab {
      place(top + right, rect(fill: gradient.linear(angle: 45deg, white, accent_color), width: 100%, height: 1em))
    } else { none }
  )

  set math.equation(numbering: "[1.1]")
  show math.equation: eq => { set block(spacing: 0.65em); eq }
  set enum(indent: 0pt, body-indent: 6pt)
  set list(indent: 0pt, body-indent: 6pt)

  // Configure headings
  show selector(heading.where(level: 1)): set heading(numbering: 
    (..nums) => h1-prefix + " " + nums.pos().map(str).join(".") + ":",
  )
  show selector(heading.where(body: [Contents])).or(
    heading.where(body: [List of Figures]).or(
      heading.where(body: [List of Tables]).or(
        heading.where(body: [List of Listings])
      )
    )
  ): set heading(numbering: none)
  show selector(heading.where(body: [References])): set heading(numbering: none)
  show heading: it => { it; v(12pt, weak: true) }


  // Configure code
  show: codly-init.with()
  codly(languages: codly-languages)
  show raw.where(block: false): it => box(fill: luma(236), inset: (x: 2pt), outset: (y: 3pt), radius: 1pt)[#it]

  // Configure figures
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: raw): it => { v(0.5em); it; v(0.5em) }

  // Title
  align(left, [#set text(22pt, weight: "bold"); #title])
  if description != none {
    align(center, box(width: 90%)[#set text(size: 12pt, style: "italic"); #description])
  }
  v(18pt, weak: true)

  // Authors
  align(left)[
    #if authors.len() > 0 {
      box(inset: (y: 10pt), {
        authors.map(author => {
          text(11pt, weight: "semibold")[
            #if "link" in author {
              [#link(author.link)[#author.name]]
            } else { author.name }]
        }).join(", ", last: if authors.len() > 2 { ", and" } else { " and" })
      })
    }
  ]
  v(6pt, weak: true)

  // Dates
  let _parsed-date = _format-notes-date(date)
  if date != none and type(_parsed-date) == datetime {
    align(left, table(
      columns: (auto, auto),
      stroke: none,
      gutter: 0pt,
      align: (right, left),
      [#text(size: 11pt, "Published:")],
      [#text(
        size: 11pt,
        fill: accent_color,
        weight: "semibold",
        _parsed-date.display(_notes-date-format)
      )],
      text(size: 11pt, "Last updated:"),
      text(
        size: 11pt,
        fill: accent_color,
        weight: "semibold",
        datetime.today().display(_notes-date-format)
      )
    ))
  } else {
    align(left,
      text(size: 11pt)[Gedruckt am :#h(5pt)] +
      text(
        size: 11pt,
        fill: accent_color,
        weight: "semibold",
        datetime.today().display(_notes-date-format)
      )
    )
  }
  v(18pt, weak: true)

  show outline.entry: it => text(fill: accent_color, it)

  // Display table of contents
  if toc {
    heading(level: 1, outlined: false)[Contents]
    outline(indent: auto, title: none)
  }

  if lof or lot or lol {
    show heading.where(level: 1): set text(size: 0.8em)
    if lof { 
      v(4pt)
      heading(level: 1)[List of Figures]
      outline(indent: auto, title: none, target: figure.where(kind: image))
    }
    if lot { 
      v(4pt)
      heading(level: 1)[List of Tables]
      outline(indent: auto, title: none, target: figure.where(kind: table))
    }
    if lol { 
      v(4pt)
      heading(level: 1)[List of Listings]
      outline(indent: auto, title: none, target: figure.where(kind: raw))
    }
    align(center)[#v(1em) * \* #sym.space.quad \* #sym.space.quad \* *]
  }
  
  v(2em, weak: true)
  set par(justify: true, linebreaks: "optimized", leading: 0.8em)

  body

  v(24pt, weak: true)
  if bibliography_file != none {
    align(center)[#v(0.5em) * \* #sym.space.quad \* #sym.space.quad \* * #v(0.5em)]
    bibliography(bibliography_file, title: [References], style: bibstyle)
  }
}

// Helper functions
#let blockquote(cite: none, body) = [
  #set text(size: 0.97em)
  #pad(left: 1.5em)[
    #block(breakable: true, width: 100%, fill: gray.lighten(90%), 
      radius: (left: 0pt, right: 5pt), stroke: (left: 5pt + gray, rest: 1pt + silver), inset: 1em)[#body]
  ]
]

#let horizontalrule = { v(1em); line(start: (37%, 0%), end: (63%, 0%), stroke: 0.5pt); v(1em) }
#let sectionline = align(center)[#v(0.5em) * \* #sym.space.quad \* #sym.space.quad \* * #v(0.5em)]
#let dboxed(content) = box(stroke: 0.5pt + black, outset: (x: 1pt, y: 8pt), inset: (x: 2pt, y: 1pt), baseline: 6pt, $$display(#content)$$)
#let iboxed(content) = box(stroke: 0.5pt + black, outset: (x: 1pt, y: 3pt), inset: (x: 2pt, y: 1pt), baseline: 1pt, $$#content$$)

// Theorem environments
#let boxnumbering = "1.1.1.1.1.1"
#let boxcounting = "heading"

#let definition = thmenv("Definition", boxcounting, none,
  (name, number, body, ..args) => {
    showybox(title: [*#name* #h(1fr) Definition #number],
      frame: (border-color: olive, title-color: olive.lighten(30%), 
        body-color: olive.lighten(95%), footer-color: olive.lighten(80%)),
      ..args.named(), body)
  }).with(numbering: boxnumbering)

#let example = thmenv("example", boxcounting, none,
  (name, number, body, ..args) => {
    showybox(title: [*#name* #h(1fr) Example #number],
      frame: (border-color: purple, title-color: purple.lighten(30%), 
        body-color: purple.lighten(95%), footer-color: purple.lighten(80%)),
      ..args.named(), body)
  }).with(numbering: boxnumbering)

#let note = thmenv("note", boxcounting, none,
  (name, number, body, ..args) => {
    showybox(title: [*#name* #h(1fr) Note #number],
      frame: (border-color: blue, title-color: blue.lighten(30%), 
        body-color: blue.lighten(95%), footer-color: blue.lighten(80%)),
      ..args.named(), body)
  }).with(numbering: boxnumbering)

#let attention = thmenv("attention", boxcounting, none,
  (name, number, body, ..args) => {
    showybox(title: [*#name* #h(1fr) Attention #number],
      frame: (border-color: rgb("#DC143C"), title-color: rgb("#DC143C").lighten(30%), 
        body-color: rgb("#DC143C").lighten(95%), footer-color: rgb("#DC143C").lighten(80%)),
      ..args.named(), body)
  }).with(numbering: boxnumbering)

#let quote = thmenv("quote", boxcounting, none,
  (name, number, body, ..args) => {
    showybox(title: [*#name* #h(1fr) Quote #number],
      frame: (border-color: black, title-color: black.lighten(30%), 
        body-color: black.lighten(95%), footer-color: black.lighten(80%)),
      ..args.named(), body)
  }).with(numbering: boxnumbering)

#let theorem = thmenv("theorem", boxcounting, none,
  (name, number, body, ..args) => {
    showybox(title: [*#name* #h(1fr) Theorem #number],
      frame: (border-color: navy, title-color: navy.lighten(30%), 
        body-color: navy.lighten(95%), footer-color: navy.lighten(80%)),
      ..args.named(), body)
  }).with(numbering: boxnumbering)

#let proposition = thmenv("Proposition", boxcounting, none,
  (name, number, body, ..args) => {
    showybox(title: [*#name* #h(1fr) Proposition #number],
      frame: (border-color: maroon, title-color: maroon.lighten(30%), 
        body-color: maroon.lighten(95%), footer-color: maroon.lighten(80%)),
      ..args.named(), body)
  }).with(numbering: boxnumbering)

#let hypothesis = thmenv("hypothesis", boxcounting, none,
  (name, number, body, ..args) => {
    showybox(title: [*#name* #h(1fr) Hypothesis #number],
      frame: (border-color: orange, title-color: orange.lighten(10%), 
        body-color: orange.lighten(95%), footer-color: orange.lighten(80%)),
      ..args.named(), body)
  }).with(numbering: boxnumbering)
