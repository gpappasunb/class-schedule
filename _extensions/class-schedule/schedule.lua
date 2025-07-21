--[[

# Description

Pandoc filter that given a markdown  Div named 'schedule' will create a class
schedule table given a strict syntax that defines the topics and contents inside the Div. The class dates are inferred from the list of elements provided.

## Formatting

The structure of the Div is:

```markdown

::: {.schedule start="29/04/2025" end="28/06/2025" days="1,3,5" headers="Class #,Day,Section,Description" dateformat="%a - %b, %d %Y"}

# Introduction

- Welcome
- Course Overview

# Linux

Installation of the Linux operating system


# Command line

## Theory

- What is a shell
- Executing commands

## Practive

- Exercises

:::

```

Explanation:

1. `::: {.schedule start="29/04/2025" end="28/06/2025" days="1,3,5" ...}`
Starts the Div (.schedule or class="schedule") and set mandatory attributes (see bellow)

2. Every level-1 (H1) header (`#`) starts a class topic, which will take exactly one row in the rendered table. The Header content is converted to plain text (strips formatting) and added to the third column of the table
** The resulting table has 4 columns: Index, Date, Header Text (Topic), Contents
** Adds automatic row numbering in first column

3. After the H1, all content will be included as the detailed contents of the class and assigned to the 4th-column (Contents). The markdown formatting is preserved for all blocks following H1 and can contain any formatting (lists, images, formatting)

4. Dates are sequenctially assigned to the given classes and placed in the second column (see bellow)

## Attributes

### Mandatory

- **start**: Starting date of the course in the format DAY-MONTH-YEAR, like "21/03/2025".
- **end**: Ending date of the course in the format DAY-MONTH-YEAR, like "21/03/2025".
- **days**: The days of the week that the class takes place. It is a comma-separated list of day indexes. The starting day is Monday and its index is "1". Thefore, for a class on Tuesdays and Thursdays the attribute shoul be:  days="2,4"
-- Day Index Reference:
	Monday: 1
	Tuesday: 2
	Wednesday: 3
	Thursday: 4
	Friday: 5
	Saturday: 6
	Sunday: 7

### Optional

- **headers**: Comma-separated list of column names for the output table. It must contain 4 elements. e.g. "Class #,Day,Section,Description" or "Class,Date,Topic,Contents". The default is is Portuguese "Aula,Data,Tópico,Conteúdo"
- **dateformat**: Any format in [Date and Times in Lua](https://www.lua.org/pil/22.1.html). The default is dateformat="%d/%m/%y".


## Installation and execution

### Pandoc

Save the file `schedule.lua` to `~/.pandoc/filters` (default directory for
pandoc filters) or any other directory. Run using one of the following
syntaxes:

``` bash
pandoc -s test.md -t html -L schedule.lua
pandoc -s test.md -t html --lua-filter=schedule.lua
pandoc -s test.md -t html -L ~/myfilters/schedule.lua   
```

The last alternative refers to the filter installed in a custom
location.

### Quarto

    quarto install extension gpappasunb/schedule

Add the filter to the document metadata:

``` markdown
---
filters:
  - schedule.lua
---
```


## Output

The filter with generate appropriate tables for the specific document rendering type. The rendered table, in markdown, is presented below. 


```markdown
+---------+--------------------+--------------+-----------------+
| **Class | **Day**            | **Section**  | **Description** |
| \#**    |                    |              |                 |
+=========+====================+==============+=================+
| 1       | Wed - Apr, 30 2025 | Introduction | - Welcome       |
|         |                    |              | - Course        |
|         |                    |              |   Overview      |
+---------+--------------------+--------------+-----------------+
| 2       | Fri - May, 02 2025 | Linux        | Installation of |
|         |                    |              | the Linux       |
|         |                    |              | operating       |
|         |                    |              | system          |
+---------+--------------------+--------------+-----------------+
| 3       | Mon - May, 05 2025 | Command line | ## Theory       |
|         |                    |              |                 |
|         |                    |              | - What is a     |
|         |                    |              |   shell         |
|         |                    |              | - Executing     |
|         |                    |              |   commands      |
|         |                    |              |                 |
|         |                    |              | ## Practive     |
|         |                    |              |                 |
|         |                    |              | - Exercises     |
+---------+--------------------+--------------+-----------------+

```


# Author

    Prof. Georgios Pappas Jr
    Computational Genomics group
    University of Brasilia (UnB) - Brazil


--]]

-- The name of the div class to trigger the filter
local DIVNAME = "schedule"

function Div(div)
	if div.classes:includes(DIVNAME) then
		local rows = {}
		local current_heading = nil
		local current_blocks = {}
		local row_index = 1
		local attributes = div.attributes

		-- require("mobdebug").start()
		-- Processing important attributes
		local attr_headers = attributes["headers"] or "Aula,Data,Tópico,Conteúdo"

		local headers = string.split(attr_headers)

		-- Parsing the dates
		local attr_start = attributes["start"]
		local attr_end = attributes["end"]

		date_start = parse_date(attr_start)
		date_end = parse_date(attr_end)

		-- These attibutes must be present!!!
		if (not attr_start) or not attr_end then
			os.exit()
		end

		-- Creating the valid date ranges
		local attr_class = attributes["class"] or "stripped"
		local attr_days = attributes["days"] or "3"
		local days = string.split(attr_days, ",")
		local allowed_days = create_allowed_days(attr_days)

		-- Date format
		local attr_dateformat = attributes["dateformat"] or "%d/%m/%y"

		local date_table = create_date_table(date_start, date_end, allowed_days, attr_dateformat)

		-- Process all blocks inside the schedule div
		for _, block in ipairs(div.content) do
			if block.t == "Header" and block.level == 1 then
				-- Finish previous row if heading exists
				if current_heading then
					table.insert(rows, create_row(row_index, date_table[row_index], current_heading, current_blocks))
					row_index = row_index + 1
				end
				-- Start new row
				current_heading = block
				current_blocks = {}
			else
				-- Collect blocks until next heading
				if current_heading then
					table.insert(current_blocks, block)
				end
			end
		end

		-- Add final row
		if current_heading then
			table.insert(rows, create_row(row_index, date_table[row_index], current_heading, current_blocks))
		end

		-- Create table structure
		local colspecs = {
			{ pandoc.AlignLeft, 0.07 },
			{ pandoc.AlignDefault, 0.23 },
			{ pandoc.AlignDefault, 0.25 },
			{ pandoc.AlignDefault, 0.45 },
		}

		local header_rows = {}
		for i = 1, #headers do
			table.insert(header_rows, pandoc.Cell(pandoc.Strong(headers[i])))
		end
		header_rows = pandoc.Row(header_rows)

		local header_col_count = tonumber(div.attr.attributes["header-cols"]) or 0
		return pandoc.Table(
			{ long = caption, short = {} },
			colspecs,
			pandoc.TableHead({ header_rows }, pandoc.Attr({ class = "stripped" })),
			-- pandoc.TableHead(headers,{}),
			{ new_table_body(rows, header_col_count) },
			pandoc.TableFoot(),
			{ class = attr_class }
		)

		-- return pandoc.Table({
		--
		-- 	caption = pandoc.Caption({}), -- No caption
		-- 	colspecs = colspecs, -- Column specifications
		-- 	head = {},           -- Empty table head
		-- 	-- bodies = { pandoc.TableBody({}, rows, 0) }, -- Table body with rows
		-- 	bodies = { rows },   -- Table body with rows
		-- 	foot = {},
		-- 	attr = {},           -- Empty table foot
		-- })
	end
end

function create_row(row_index, date, heading, blocks)
	-- Convert heading content to plain text string
	local heading_text = pandoc.utils.stringify(heading.content)

	-- Create table cells
	local cell_index = pandoc.Cell({ pandoc.Plain({ pandoc.Str(tostring(row_index)) }) })
	local cell_date = pandoc.Cell({ pandoc.Plain({ pandoc.Str(date) }) })
	local cell_topic = pandoc.Cell({ pandoc.Plain({ pandoc.Str(heading_text) }) })
	local cell_contents = pandoc.Cell(blocks)

	return pandoc.Row({ cell_index, cell_date, cell_topic, cell_contents })
end

function new_table_body(rows, header_col_count)
	return {
		attr = {},
		body = rows,
		head = {},
		row_head_columns = header_col_count,
	}
end

function string.split(input, delimiter)
	local result = {}
	delimiter = delimiter or ","
	for value in string.gmatch(input, "([^" .. delimiter .. "]+)") do
		table.insert(result, value:match("^%s*(.-)%s*$")) -- Trim whitespace
	end
	return result
end

-- in lua, how to I create a table of dates having the start and end days, and the index of the days in a week that are allowed to be selected?
function create_date_table(startDate, endDate, allowedDays, dateFormat)
	local dateTable = {}

	dateFormat = dateFormat or "%Y-%m-%d"

	-- Convert start and end dates to timestamps
	-- local startTime = os.time(startDate)
	-- local endTime = os.time(endDate)
	-- local startTime = os.date("*t", startDate)
	-- local endTime = os.date("*t", endDate)

	-- Iterate through each day between start and end
	-- for currentTime = startTime, endTime, 24 * 60 * 60 do
	for currentTime = startDate, endDate, 24 * 60 * 60 do
		local currentDate = os.date("*t", currentTime)
		local dayOfWeek = currentDate.wday - 1 -- Convert to 0-6 format

		-- Check if the current day is allowed
		if allowedDays[dayOfWeek] then
			table.insert(dateTable, os.date(dateFormat, currentTime))
		end
	end

	return dateTable
end

function parse_date(datestr, american)
	local pattern = "(%d+)[/-](%d+)[/-](%d+)"
	local year, month, day

	if american then
		month, day, year = datestr:match(pattern)
	else
		day, month, year = datestr:match(pattern)
	end

	local timestamp = os.time({
		year = year,
		month = month,
		day = day,
	})
	return timestamp
end

function create_allowed_days(dayindexstr)
	local allowed_days = { false, false, false, false, false, false, false } -- Days starting on Mon, Wed, Thu, Sun

	local day_list = string.split(dayindexstr)
	for i, d in ipairs(day_list) do
		local day_number = tonumber(d)
		allowed_days[day_number] = true
	end
	return allowed_days
end

-- Example usage
-- local startDate = { year = 2025, month = 7, day = 1 }
-- local endDate = { year = 2025, month = 7, day = 31 }
-- local allowedDays = { true, false, true, true, false, false, true } -- Mon, Wed, Thu, Sun
--
-- local selectedDates = createDateTable(startDate, endDate, allowedDays)
--
-- -- Print the selected dates
-- for _, date in ipairs(selectedDates) do
-- 	print(date)
-- end
