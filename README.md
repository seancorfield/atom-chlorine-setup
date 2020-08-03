# Atom/Chlorine Setup

The files here represent my current [Atom](https://atom.io/) configuration for use with [Chlorine](https://atom.io/packages/chlorine) **version 0.7.3 or later** (since it relies on the recently-added _experimental_ ClojureScript extension feature).

The commands here will `submit` all evaluations to [Cognitect's REBL](https://github.com/cognitect-labs/REBL-distro) if it is on your classpath, otherwise it `tap>`'s all evaluations. If you have a [Reveal REPL](https://github.com/vlaaad/reveal) running that will render everything that is `tap>`'d into its UI. If you have a [Portal UI](https://github.com/djblue/portal) running that will also render everything that is `tap>`'d into its UI.

* `chlorine-config.cljs` contains all my enhancements,
* `init.coffee` contains some extended paredit features,
* `keymap.cson` is my cross-platform key mappings for Chlorine and those REBL/`tap>` commands.

## Installation

You can either clone this repo into a temporary directory and then copy those three files into your `~/.atom` directory (overwriting the default `init.coffee` and `keymap.cson` files and any Chlorine config file you may have already created), or you can clone it on top of your existing `~/.atom` so that you can keep it updated to match this repo by pulling new changes as desired:

```bash
$ cd ~/.atom
$ git init
$ git remote add origin https://github.com/seancorfield/atom-chlorine-setup.git
$ git fetch
$ git checkout develop -f
```

That last line will overwrite any existing versions of those three files.

To update your files to the latest versions from this repo:

```bash
$ cd ~/.atom
$ git pull
```

## Keymap

The additional commands _require_ Clojure 1.10 (because they assume `requiring-resolve` and `tap>`) and will fail on earlier versions. REBL, Reveal, and Portal both support Clojure 1.10's `datafy` and `nav`. If you need to work on an earlier project, you'll need to use Chlorine's default versions of the commands.

* `ctrl-; b` -- evaluate current form into REBL/`tap>`.
* `ctrl-; B` -- evaluate current top-level form into REBL/`tap>`.
* `ctrl-; c` -- Chlorine's built-in break evaluation.
* `ctrl-; d` -- Chlorine's built-in show docs for var. See also `j` and `?` below.
* `ctrl-; D` -- when a binding in `let` is highlighted (both the symbol and the expression to which it is bound), this creates a `def` so the symbol becomes available at the top level: useful for debugging parts of a function inside `let`.
* `ctrl-; e` -- Chlorine's built-in disconnect (from the REPL).
* `ctrl-; f` -- Chlorine's built-in load file.
* `ctrl-; j` -- treat the var at the cursor (or the current selection) as a Java class or instance, lookup the Java API docs for it, and display that web page in REBL (assumes the class is part of the Java Standard Library) or `tap>` the `java.net.URL` object (which can be browsed in Reveal or clicked in Portal).
* `ctrl-; k` -- Chlorine's built-in clear console.
* `ctrl-; K` -- Chlorine's built-in clear inline results.
* `ctrl-; n` -- inspect the current namespace in REBL (Reveal and Portal do not currently do anything special with a namespace).
* `ctrl-; r` -- remove the current namespace's definitions: useful for cleaning up REPL state.
* `ctrl-; R` -- reload the current namespace and all of its dependencies (uses `(require ,,, :reload-all)`: useful for cleaning up REPL state.
* `ctrl-; s` -- evaluate the selected code into REBL/`tap>` -- it can only be a single form (it will be used as the expression in a `let` binding).
* `ctrl-; S` -- Chlorine's built-in show source for var.
* `ctrl-; t` -- Chlorine's built-in run test for var.
* `ctrl-; v` -- inspect the current symbol in REBL (as a var; Reveal and Portal do not currently do anything special with vars, unlike REBL).
* `ctrl-; x` -- Chlorine's built-in run tests in (current) namespace.
* `ctrl-; X` -- If the current namespace is `foo.bar`, attempt to run tests in either `foo.bar-test` or `foo.bar-expectations`, display the test results in a popup (as per Chlorine's built-in test runner), display that summary inline as a hash map, and submit it to REBL/`tap>`.
* `ctrl-; y` -- Chlorine's built-in connect to Socket REPL.
* `ctrl-; ?` -- for the var at the cursor, display the ClojureDocs web page for it in REBL (assumes the symbol is part of Clojure itself) or `tap>` the `java.net.URL` object (which can be browsed in Reveal or clicked in Portal).
* `ctrl-; .` -- Chlorine's built-in go to var definition.

### Extended Paredit

* `alt-; c` -- copy current s-expression
* `alt-; v` -- paste over current s-expression
* `alt-; x` -- cut current s-expression
* `alt-; backspace` -- delete current s-expression

### Linter   

* `alt-; n` -- jump to the linter's next warning.

### Miscellaneous

* `enter` -- Paredit's `newline` command (you probably don't need this -- I added it because it seemed to disappear after an update to Paredit)
