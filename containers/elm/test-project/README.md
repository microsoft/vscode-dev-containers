# Elm

[Elm](https://elm-lang.org/) is a programming language that compiles to JavaScript. It is known for its friendly error messages, helping you find issues quickly and refactor large projects with confidence. Elm is also [very fast](https://elm-lang.org/blog/blazing-fast-html-round-two) and [very small](https://elm-lang.org/blog/small-assets-without-the-headache) when compared with React, Angular, Ember, etc.

This repo focuses on **The Elm Architecture**, an architecture pattern you see in all Elm programs. It has influenced projects like Redux that borrow core concepts but add many JS-focused ideas.


## The Elm Architecture

The Elm Architecture is a simple pattern for architecting webapps. The core idea is that your code is built around a `Model` of your application state, a way to `update` your model, and a way to `view` your model.

To learn more about this, read the [the official guide][guide] and check out [this section][arch] which is all about The Elm Architecture. This repo is a collection of all the examples in that section, so you can follow along and compile things on your computer as you read through.

[guide]: https://guide.elm-lang.org/
[arch]: https://guide.elm-lang.org/architecture/


## Run The Examples

After you [install](https://guide.elm-lang.org/install.html), run the following commands in your terminal to download this repo and start a server that compiles Elm for you:

```bash
git clone https://github.com/evancz/elm-architecture-tutorial.git
cd elm-architecture-tutorial
elm reactor
```

Now go to [http://localhost:8000/](http://localhost:8000/) and start looking at the `examples/` directory. When you edit an Elm file, just refresh the corresponding page in your browser and it will recompile!
