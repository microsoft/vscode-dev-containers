# [{{definition}}](https://github.com/{{repository}}/tree/main/containers/{{definition}})
{{#if annotation}}
{{{annotation}}}
{{/if}}

**Image version:** {{version}}

**Source release/branch:** [{{release}}](https://github.com/{{repository}}/tree/{{release}}/containers/{{definition}})

**Supported architectures:**
{{#each architectures}}
- {{this}}
{{/each}}

{{#if hasVariants}}
**Definition variations:**
{{#each variants}}
- [{{this}}](#variant-{{anchor this}})
{{/each}}

{{/if}}