#show: template.with(
$if(title)$
  title: [$title$],
$endif$
$if(short-title)$
  short_title: "$short-title$",
$endif$
$if(subtitle)$
  description: [$subtitle$],
$endif$
$if(date)$
  date: "$date$",
$endif$
$if(by-author)$
  authors: (
$for(by-author)$
    (
      name: "$it.name.literal$",
$if(it.url)$
      link: "$it.url$",
$endif$
    ),
$endfor$
  ),
$endif$
$if(toc)$
  toc: $toc$,
$endif$
$if(lof)$
  lof: $lof$,
$endif$
$if(lot)$
  lot: $lot$,
$endif$
$if(lol)$
  lol: $lol$,
$endif$
$if(bibliography)$
  bibliography_file: "$bibliography$",
$endif$
$if(csl)$
  bibstyle: "$csl$",
$elseif(bibstyle)$
  bibstyle: "$bibstyle$",
$endif$
$if(papersize)$
  paper_size: "$papersize$",
$endif$
$if(landscape)$
  landscape: $landscape$,
$endif$
$if(columns)$
  cols: $columns$,
$endif$
$if(mainfont)$
  text_font: "$mainfont$",
$endif$
$if(monofont)$
  code_font: "$monofont$",
$endif$
$if(accent-color)$
  accent: rgb("#$accent-color$"),
$endif$
$if(h1-prefix)$
  h1-prefix: "$h1-prefix$",
$endif$
$if(colortab)$
  colortab: $colortab$,
$endif$
)
