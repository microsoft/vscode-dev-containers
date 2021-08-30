{{#if variant}}
## Variant: {{variant}}

{{/if}}
**Digest:** {{image.digest}}

**Tags:**
```
{{#each tags}}
{{this}}
{{/each}}
```
> *To keep up to date, we recommend using partial version numbers. Use the major version number to get all non-breaking changes (e.g. `0-`) or major and minor to only get fixes (e.g. `0.200-`).*

**Linux distribution:** {{distro.prettyName}}{{#if distro.idLike}} ({{distro.idLike}}-like distro){{/if}}

**Architectures:** {{architectures}}

**Available (non-root) user:** {{image.user}}

### Contents
{{#if languages}}
**Languages and runtimes**

| Language / runtime | Version | Path |
|--------------------|---------|------|
{{#each languages}}
| {{#if this.url}}[{{this.name}}]({{this.url}}){{/if}}{{#unless this.url}}{{this.name}}{{/unless}}{{#if this.annotation}} ({{this.annotation}}){{/if}} | {{{this.version}}} | {{#if this.path}}{{{this.path}}} |{{/if}}
{{/each}}

{{/if}}
{{#if git}}
**Tools installed using git**

| Tool | Commit | Path |
|------|--------|------|
{{#each git}}
| {{#if this.url}}[{{this.name}}]({{this.url}}){{/if}}{{#unless this.url}}{{this.name}}{{/unless}}{{#if this.annotation}} ({{this.annotation}}){{/if}} | {{{this.version}}} | {{#if this.path}}{{{this.path}}} |{{/if}}
{{/each}}

{{/if}}
{{#if hasPip}}
**Pip / pipx installed tools and packages**

| Tool / package | Version |
|----------------|---------|
{{#each pip}}
| {{#if this.url}}[{{this.name}}]({{this.url}}){{/if}}{{#unless this.url}}{{this.name}}{{/unless}}{{#if this.annotation}} ({{this.annotation}}){{/if}} | {{{this.version}}} |
{{/each}}
{{#each pipx}}
| {{#if this.url}}[{{this.name}}]({{this.url}}){{/if}}{{#unless this.url}}{{this.name}}{{/unless}}{{#if this.annotation}} ({{this.annotation}}){{/if}} | {{{this.version}}} |
{{/each}}

{{/if}}
{{#if npm}}
**Npm globally installed tools and packages**

| Tool / package | Version |
|----------------|---------|
{{#each npm}}
| {{#if this.url}}[{{this.name}}]({{this.url}}){{/if}}{{#unless this.url}}{{this.name}}{{/unless}}{{#if this.annotation}} ({{this.annotation}}){{/if}} | {{{this.version}}} |
{{/each}}

{{/if}}
{{#if go}}
**Go tools and modules**

| Tool / module | Version |
|---------------|---------|
{{#each go}}
| {{#if this.url}}[{{this.name}}]({{this.url}}){{/if}}{{#unless this.url}}{{this.name}}{{/unless}}{{#if this.annotation}} ({{this.annotation}}){{/if}} | {{{this.version}}} |
{{/each}}

{{/if}}
{{#if gem}}
**Ruby gems and tools**

| Tool / gem | Version |
|------------|---------|
{{#each gem}}
| {{#if this.url}}[{{this.name}}]({{this.url}}){{/if}}{{#unless this.url}}{{this.name}}{{/unless}}{{#if this.annotation}} ({{this.annotation}}){{/if}} | {{{this.version}}} |
{{/each}}

{{/if}}
{{#if cargo}}
**Cargo / rustup (Rust) crates and tools**

| Tool / crate | Version |
|--------------|---------|
{{#each cargo}}
| {{#if this.url}}[{{this.name}}]({{this.url}}){{/if}}{{#unless this.url}}{{this.name}}{{/unless}}{{#if this.annotation}} ({{this.annotation}}){{/if}} | {{{this.version}}} |
{{/each}}

{{/if}}
{{#if other}}
**Other tools and utilities**

| Tool | Version | Path |
|------|---------|------|
{{#each other}}
| {{#if this.url}}[{{this.name}}]({{this.url}}){{/if}}{{#unless this.url}}{{this.name}}{{/unless}}{{#if this.annotation}} ({{this.annotation}}){{/if}} | {{{this.version}}} | {{#if this.path}}{{{this.path}}} |{{/if}}
{{/each}}

{{/if}}
{{#if linux}}
**Additional linux tools and packages**

| Tool / library | Version |
|----------------|---------|
{{#each linux}}
| {{#if this.url}}[{{this.name}}]({{this.url}}){{/if}}{{#unless this.url}}{{this.name}}{{/unless}}{{#if this.annotation}} ({{this.annotation}}){{/if}} | {{{this.version}}} |
{{/each}}

{{/if}}
