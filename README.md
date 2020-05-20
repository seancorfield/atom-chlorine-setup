# Atom/Chlorine Setup

The files here represent my current [Atom](https://atom.io/) configuration for use with [Chlorine](https://atom.io/packages/chlorine) **version 0.6.1 or later** (since it relies on the recently-added experimental ClojureScript extension feature).

* `init.coffee` primarily contains REBL-specific commands to inspect Vars and namespaces,
* `keymap.cson` is my cross-platform key mappings for Chlorine and those REBL commands.

## Keymap

The REBL-specific commands _require_ Clojure 1.10 and will fail on earlier versions. Since REBL depends on `datafy`/`nav` in Clojure 1.10, this seemed like a reasonable baseline to me. If you need to work on an earlier project, you'll need to use Chlorine's default versions of the commands.

* `ctrl-; b` -- evaluate current form into REBL.
* `ctrl-; B` -- evaluate current top-level form into REBL.
* `ctrl-; c` -- Chlorine's built-in break evaluation.
* `ctrl-; d` -- Chlorine's built-in show docs for var. See also `j` and `?` below.
* `ctrl-; D` -- when a binding in `let` is highlighted (both the symbol and the expression to which it is bound), this creates a `def` so the symbol becomes available at the top level: useful for debugging parts of a function inside `let`.
* `ctrl-; e` -- Chlorine's built-in disconnect (from the REPL).
* `ctrl-; f` -- Chlorine's built-in load file.
* `ctrl-; j` -- treat the var at the cursor (or the current selection) as a Java class or instance, lookup the Java API docs for it, and display that web page in REBL (assumes the class is part of the Java Standard Library).
* `ctrl-; k` -- Chlorine's built-in clear console.
* `ctrl-; K` -- Chlorine's built-in clear inline results.
* `ctrl-; n` -- inspect the current namespace in REBL (cursor must be after the `ns` form due to a limitation in Chlorine).
* `ctrl-; r` -- remove the current namespace's definitions: useful for cleaning up REPL state (cursor must be after the `ns` form due to a limitation in Chlorine).
* `ctrl-; R` -- reload the current namespace and all of its dependencies (uses `(require ,,, :reload-all)`: useful for cleaning up REPL state (cursor must be after the `ns` form due to a limitation in Chlorine).
* `ctrl-; s` -- evaluate the selected code into REBL.
* `ctrl-; S` -- Chlorine's built-in show source for var.
* `ctrl-; t` -- Chlorine's built-in run test for var.
* `ctrl-; v` -- inspect the current symbol in REBL (as a var).
* `ctrl-; x` -- Chlorine's built-in run tests in (current) namespace.
* `ctrl-; y` -- Chlorine's built-in connect to Socket REPL.
* `ctrl-; ?` -- for the var at the cursor, display the ClojureDocs web page for it in REBL (assumes the symbol is part of Clojure itself).
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
