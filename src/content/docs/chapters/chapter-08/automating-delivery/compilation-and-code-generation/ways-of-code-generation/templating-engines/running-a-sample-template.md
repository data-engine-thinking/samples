---
title: "Running a Sample Template"
---

This example shows how a templating engine turns a metadata file and a template into a working SQL statement.

Download the `RunDsaAutomation` executable from the [data solution automation releases page](https://github.com/data-engine-thinking/data-solution-automation-metadata-schema/releases/) and place it in a working directory with an `input` folder for the metadata and a `templates` folder for the template.

## The metadata

The metadata describes a single mapping: a source data object, a target (`SomeCustomerTable`), and two source-to-target column mappings.

```json file=<rootDir>/chapters/chapter-08/automating-delivery/compilation-and-code-generation/ways-of-code-generation/templating-engines/running-a-sample-template/input/MyFirstMapping.json
```

## The template

The Handlebars template loops over the mappings and renders a `SELECT` statement, aliasing each source column to its target name.

```handlebars file=<rootDir>/chapters/chapter-08/automating-delivery/compilation-and-code-generation/ways-of-code-generation/templating-engines/running-a-sample-template/templates/myFirstTemplate.handlebars
```

## Running it

From the directory where the executable resides, run:

```bash
.\RunDsaAutomation -i ".\input\MyFirstMapping.json" -p ".\templates\myFirstTemplate.handlebars" -v -o -d .\output -e sql
```

The flags point the engine at the metadata and template and control the output:

- `-i` — input metadata (mapping) file
- `-p` — template to apply
- `-o` — write the result to a file
- `-d` — output directory
- `-e` — output file extension
- `-v` — verbose logging

## The result

The engine combines the metadata with the template and writes a `.sql` file to the `output` folder:

```sql
--Example using a templating engine for a simple select statement.

--Working on MyFirstMapping.

SELECT
ColumnOneSource AS CustomerId,
ColumnTwoSource AS CustomerName
FROM [SomeCustomerTable]
WHERE CustomerId!=NULL
```
