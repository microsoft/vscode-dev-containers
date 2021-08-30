# [{{definition}}](https://github.com/{{repository}}/tree/main/containers/{{definition}})
{{#if annotation}}
{{{annotation}}}
{{/if}}

**Image version:** {{version}}

**Source release/branch:** [{{release}}](https://github.com/{{repository}}/tree/{{release}}/containers/{{definition}})

{{#if hasVariants}}
**Definition variations:**
{{#each variants}}
- [{{this}}](#variant-{{anchor this}})
{{/each}}

{{/if}}