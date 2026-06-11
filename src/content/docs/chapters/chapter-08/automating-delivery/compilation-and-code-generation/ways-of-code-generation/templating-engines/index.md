---
title: "Templating Engines"
sidebar:
  order: 1
---

:::note[In the book]
This page accompanies the *Ways of code generation* section of *Data Engine Thinking* (Chapter 8); the book links here via `dtng.link/hb2ay` and `dtng.link/feww1`.
:::

At the time of writing, many freely available libraries are available such as for example Mustache/Handlebars, Scriban, Jinja, Pebble, and many more.

The provided templates are primarily created using Handlebars.

## Logicless Or Not?

Templating engines are often categorized as either logicless or logic-enabled, depending on whether they support advanced features like variables, parameters, and control structures such as case statements. For example, Handlebars is considered a logicless templating engine because it deliberately limits logic to promote separation of concerns. In contrast, Jinja (used in Python) or Liquid (used in Shopify and Jekyll) are logic-enabled and allow more complex expressions, loops, and conditionals directly within templates.

The decision to use logicless or logic-enabled templates depends on how much complexity is captured in metadata versus in the template code itself. Logic-enabled templates offer more flexibility and features, but they also make it easier to introduce workarounds for limitations in the metadata. In contrast, logicless templates require the metadata to be complete and expressive enough to support all necessary rendering logic, encouraging better separation of concerns.

As an example, consider these syntax differences between Handlebars and Jinja.

| Feature           | Handlebars Example                              | Jinja Example                                       |
|-------------------|--------------------------------------------------|-----------------------------------------------------|
| **Variable**       | `{{ name }}`                                     | `{{ name }}`                                         |
| **If condition**   | `{{#if is_admin}}Welcome{{/if}}`                 | `{% if is_admin %}Welcome{% endif %}`               |
| **Else**           | `{{#if is_admin}}Yes{{else}}No{{/if}}`           | `{% if is_admin %}Yes{% else %}No{% endif %}`       |
| **Loop**           | `{{#each items}}<li>{{this}}</li>{{/each}}`      | `{% for item in items %}<li>{{ item }}</li>{% endfor %}` |
| **Function / Logic** | *Not allowed in template* (must pre-process)   | `{% set total = price * quantity %}`                |

## Frameworks

An easy way to start working with templating engines, is to download the [Schema for Data Solution automation](https://github.com/data-solution-automation-engine/data-warehouse-automation-metadata-schema) repository and execute/modify the examples made available here.

## Software

* [Agnostic Data Labs (ADL)](https://agnosticdatalabs.com/) is a new data automation solution that follows the concepts and patterns described in Data Engine Thinking. It requires registration, but provides a convenient user interface to simplify working with templates - and provides a large repository of runnable samples.

## Giving It A Go

The template samples directory in this repository provides runnable examples — see [Running a Sample Template](/chapters/chapter-08/automating-delivery/compilation-and-code-generation/ways-of-code-generation/templating-engines/running-a-sample-template/).
