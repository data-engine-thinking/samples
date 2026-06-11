---
title: "Domain-Specific Languages"
sidebar:
  order: 2
  label: "BIML"
---

:::note[In the book]
This page accompanies the *Domain-specific languages* discussion in *Data Engine Thinking* (Chapter 8) — an alternative to templating engines for the same goal; the book links here via `dtng.link/emlz8`.
:::

A domain-specific language (DSL) provides an alternative to a general-purpose templating engine. This can be demonstrated with a sample template script that uses the Biml DSL. Consider the code below, a mixture of C# and the template using Biml (XML) syntax.

```xml file=<rootDir>/chapters/chapter-08/automating-delivery/compilation-and-code-generation/ways-of-code-generation/domain-specific-languages/biml-template.biml
```

The C# blocks (`<# … #>`) read every JSON metadata file in a directory and deserialize each one into the same data object mappings used throughout these samples. For each mapping, the script emits an SSIS package with two chained data flow tasks — the second running after the first through a precedence constraint.

## Executing the script

Biml is processed by a Biml compiler, which runs the embedded C# to expand the metadata and then generates the target packages. The most common free option is [BimlExpress](https://www.varigence.com/bimlexpress), an add-in for Visual Studio; Biml Studio is the commercial IDE.

A typical run with BimlExpress:

1. Replace `<directory containing JSON files>` with the folder that holds your JSON mapping files.
2. Make the `DataObjectMappings` object model and Json.NET available to the script (for example, by referencing the schema's class library).
3. Add the `.biml` file to an Integration Services project in Visual Studio, right-click it, and choose **Generate SSIS Packages**.

The compiler expands the BimlScript — reading and deserializing each metadata file — and emits the packages.

## Expected output

The expansion produces one package per data object mapping. For a mapping named `Customer`, the script expands to:

```xml
<Packages>
  <Package Name="Customer1">
    <Tasks>
      <Dataflow Name="DF - Customer1 - 1">
      </Dataflow>
      <Dataflow Name="DF - Customer1 - 2">
        <PrecedenceConstraints>
          <Inputs>
            <Input OutputPathName="DF - Customer1 - 1.Output" />
          </Inputs>
        </PrecedenceConstraints>
      </Dataflow>
    </Tasks>
  </Package>
</Packages>
```

Compiling this Biml produces the corresponding SSIS packages (`.dtsx`), each containing the two data flow tasks shown. Biml can also target Azure — generating Azure Data Factory pipelines and mapping data flows — from the same metadata-driven approach.
