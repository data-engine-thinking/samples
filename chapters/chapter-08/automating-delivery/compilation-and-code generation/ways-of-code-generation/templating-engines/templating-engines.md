# Templating Engines

At the time of writing, many freely available libraries are available such as for example Mustache/Handlebars, Scriban, Jinja, Pebble, and many more.

The provides templates are primarily created using Handlebars.

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

## Giving It A Go

The template samples directory in this repository provides examples taken from the 