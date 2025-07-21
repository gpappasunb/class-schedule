# Class Schedule Example
Georgios Pappas Jr
2025-07-21

## Introduction

The `class-schedule-pdf` Quarto extension allows you to create a PDF
document featuring a specially formatted list of topics scheduled across
a defined range of dates. You can easily select recurring days of the
week for each topic, making this extension especially useful for
designing a syllabus or class schedule. Classes are displayed in a table
format, listing topics, corresponding dates, and any additional
descriptions you wish to include.

> [!NOTE]
>
> ### Additional use cases for this extension include:
>
> - Creating a schedule for a conference, a workshop, or any other event
>   that requires a structured list of topics with dates and
>   descriptions.
> - Organizing travel itineraries by listing destinations along with
>   their corresponding dates and descriptions.
> - Outlining project timelines, detailing tasks to be completed along
>   with their deadlines and descriptions.
> - Creating meeting agendas.
> - Managing to-do lists by listing tasks and their descriptions.

To create a class schedule document using the `class-schedule-pdf`
format, follow a specific structure and syntax in your Quarto document.
The guide below explains how to set up your document, including the
required metadata and the schedule definition syntax.

## Metadata

The metadata at the top of your document defines the standard Quarto
options used to render the document. The `class-schedule-pdf` format is
a custom option that utilizes a dedicated LaTeX template to produce the
schedule as a PDF.

### Mandatory metadata

Be sure to set the `format` to `class-schedule-pdf` in the YAML metadata
at the top of your document. This ensures Quarto uses the custom class
schedule format when rendering the PDF.

``` yaml
format: class-schedule-pdf
```

### Regular metadata

title  
The title will appear at the top of the document, and will be something
like “Syllabus”.

subtitle  
Below the title, and can be used to provide additional information, such
as the course name and semester.

author  
Author name (Optional)

date  
The date of the document, which can be set to `last-modified` to
automatically use the last modified date of the file. (Optional)

### Customization metadata

You can also customize the appearance of the document by adding
additional metadata. For example, you can set the `logo` to include a
logo image, and specify its placement and height.

logo  
The path to the logo image file. This is optional, but if you want to
include a logo, you should specify it here.

logo-placement  
The placement of the logo in the document. It can be set to `L` (left)
or `C` (center). The default is `L`.

logo-height  
The height of the logo in the document. This is optional, but if you
want to include a logo, you should specify its height in points (e.g.,
`40pt`).

logo-text  
The text to be displayed at the rightmost side of the page header
(optional), containing information such as the university name and
department. One important thing to note is that the text can be
multi-line; in this case, you should use the `|` character to indicate
that the text is multi-line, and each line should be indented according
to YAML syntax. Also, to display two lines, you **must** use a blank and
indented line between the two lines of text.

color  
The color of the header in the document, headings and alternating table
rows. It is an RGB color code in the form AA39CC, without the `#`
symbol.

color-odd  
The color of the odd rows in the schedule table. The default is the same
as `color`.

color-even  
The color of the even rows in the schedule table. The default is
`ffffff` (white).

color-heading  
The color of the decoration in the section headings in the document. The
color of the heading text itself is set with the metadata attribute
`sansfontoptions` (see [quarto PDF document
fonts](https://quarto.org/docs/output-formats/pdf-basics.html#fonts)).

heading-format  
A boolean value that indicates whether to use a special format for the
section headings. If set to `true`, the section headings will be
rendered with a filled box around the section number. The default is
`true`.

> [!TIP]
>
> Refer to the template document for examples of how to utilize these
> metadata attributes. A full list of metadata attributes can be found
> in the file `_extensions/class-schedule/_extension.yml` in the
> `class-schedule` extension directory.

## Schedule syntax

Define the schedule with the `::: {.schedule}` div syntax. Begin each
class day or topic with a `#` header (e.g., `# Introduction`), followed
by a class description in standard markdown. Use sub-headers (e.g.,
`## Theory`) to organize sections within a class description. Class
numbers and dates are automatically generated from the `start` and `end`
attributes in the `schedule` div.

``` mardown
::: {.schedule 
start="29/04/2025" 
end="28/06/2025" 
days="1,3,5" 
headers="Class,Day,Section,Description" 
dateformat="%a - %b, %d %Y"}

# Class 1 
Description of class 1.

# Class 2
Description of class 2.

::: 
```

### Div attributes

The `schedule` div accepts several attributes:

- `start`: The start date of the schedule in the format `dd/mm/yyyy`.
  **Important**: The order is revelant, so the first two digits refer to
  the day.
- `end`: The end date of the schedule in the format `dd/mm/yyyy`.
- `days`: A comma-separated list of days of the week (1 for Monday, 2
  for Tuesday, etc.). This describes the days on which the events occur.
- `headers`: A comma-separated list of headers for the table
  (e.g. `Class,Day,Section,Description`). These are used to label the
  columns in the table and should be four in total, and the order is
  fixed.
- `dateformat`: The format for displaying dates in the table
  (e.g. `%a - %b, %d %Y` for abbreviated weekday, month, day, and year).
  This for the final display of the dates in the table, and you can use
  any valid [strftime format](https://strftime.org/).

## Installation

To use the `class-schedule-pdf` format, you need to have the `quarto`
command line tool installed. You can install it from [Quarto’s official
website](https://quarto.org/docs/get-started/).

You also need to have the `class-schedule` extension installed. You can
install it by running the following command in your terminal:

``` bash
quarto install class-schedule
```

## How to render the schedule

``` bash
quarto render --to class-schedule-pdf template.qmd
```

If you have the `format` metadata set to `class-schedule-pdf` in the
YAML metadata, you can simply run:

``` bash
quarto render template.qmd
```

## Some formatting tips

### Text outside the schedule

Standard Quarto markdown syntax applies, so you can use any formatting
described in [Quarto Markdown
Basics](https://quarto.org/docs/authoring/markdown-basics.html). Each
topic should begin with a level 2 header (`##`), which will be numbered
automatically. You can also use other header levels, but these will not
be numbered.

### Highlights

To highlight text in the schedule or body, use the `\hl{}` command in
LaTeX. For example, to highlight bold text, use
`\hl{\textbf{bold highlighted text}}` $\Rightarrow$ .

To change the highlight background color, use `\sethlcolor{red}` before
`\hl{RED highlighted text}`. The first command sets the color for the
following highlighted text but is not rendered in the document (e.g.,
`\sethlcolor{red}\hl{RED highlighted text}`).

> [!NOTE]
>
> This LaTeX code is designed specifically for PDF documents. For a more
> versatile method of highlighting text, consider using the
> [mcanouil/quarto-highlight-text](https://github.com/mcanouil/quarto-highlight-text?tab=readme-ov-file)
> extension.

## Rendered schedule

> [!NOTE]
>
> The full document will look like this: [demo PDF](README.pdf). Check
> source code for the rendered schedule in the `README.qmd` file.

<table class="stripped">
<colgroup>
<col style="width: 7%" />
<col style="width: 23%" />
<col style="width: 25%" />
<col style="width: 45%" />
</colgroup>
<thead class="stripped">
<tr>
<th style="text-align: left;"><strong>Class</strong></th>
<th><strong>Day</strong></th>
<th><strong>Section</strong></th>
<th><strong>Description</strong></th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align: left;">1</td>
<td>Wed - Apr, 30 2025</td>
<td>Introduction</td>
<td><p>Regular text of the description.</p></td>
</tr>
<tr>
<td style="text-align: left;">2</td>
<td>Fri - May, 02 2025</td>
<td>Introduction (cont.)</td>
<td><p>Any text can be added here, including lists:</p>
<ul>
<li>Welcome</li>
<li>Course Overview</li>
</ul></td>
</tr>
<tr>
<td style="text-align: left;">3</td>
<td>Mon - May, 05 2025</td>
<td>Sub-header</td>
<td><p>You can also have sub-headers in the table, which will be
rendered as a separate row in the table. Add <code>##</code> for a
sub-header. The class <code>{.unnumbered}</code> is important to avoid
mixing up the numbering with regular level 2 headers.</p>
<h2 id="theory" class="unnumbered">Theory</h2>
<ul>
<li>Topic 1</li>
<li>Topic 2</li>
</ul>
<h2 id="practice" class="unnumbered">Practice</h2>
<ul>
<li>Exercises</li>
</ul></td>
</tr>
<tr>
<td style="text-align: left;">4</td>
<td>Wed - May, 07 2025</td>
<td>Another class</td>
<td><p>Another formatting is the <a
href="https://quarto.org/docs/authoring/markdown-basics.html#lists">definition
list</a> notation below. The two spaces after the colon (:) are
important to render the definition list correctly.:</p>
<dl>
<dt>Practice exercises</dt>
<dd>
&#10;</dd>
</dl>
<ol class="example" type="1">
<li>Exercises 1</li>
<li>Exercises 2</li>
<li>Exercises 3</li>
</ol>
<ul>
<li>Computer lab
<ol type="1">
<li>Exercises 1</li>
</ol></li>
</ul></td>
</tr>
<tr>
<td style="text-align: left;">5</td>
<td>Fri - May, 09 2025</td>
<td>Class XXX</td>
<td><p>This is a class with a very long description that will be wrapped
in the table cell. It should be long enough to demonstrate how the text
wraps around in the table cell. This is useful for showing how the
schedule can accommodate longer descriptions without breaking the
layout.</p></td>
</tr>
</tbody>
</table>
