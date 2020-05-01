# Your init script
#
# Atom will evaluate this file each time a new window is opened. It is run
# after packages are loaded/activated and after the previous editor state
# has been restored.
#
# An example hack to log to the console when each text editor is saved.
#
# atom.workspace.observeTextEditors (editor) ->
#   editor.onDidSave ->
#     console.log "Saved! #{editor.getPath()}"
# These add some convenience commands for cutting, copying, pasting, deleting, and indenting Lisp expressions.

# Applies the function f and then reverts the cursor positions back to their original location
maintainingCursorPosition = (f)->
  editor = atom.workspace.getActiveTextEditor()
  currSelected = editor.getSelectedBufferRanges()
  f()
  editor.setSelectedScreenRanges(currSelected)

# Cuts the current block of lisp code.
atom.commands.add 'atom-text-editor', 'jason:cut-sexp', ->
  editor = atom.workspace.getActiveTextEditor()
  atom.commands.dispatch(atom.views.getView(editor), 'lisp-paredit:up-sexp')
  atom.commands.dispatch(atom.views.getView(editor), 'lisp-paredit:expand-selection')
  atom.commands.dispatch(atom.views.getView(editor), 'core:cut')

# Copies the current block of lisp code.
atom.commands.add 'atom-text-editor', 'jason:copy-sexp', ->
  maintainingCursorPosition ->
    editor = atom.workspace.getActiveTextEditor()
    atom.commands.dispatch(atom.views.getView(editor), 'lisp-paredit:up-sexp')
    atom.commands.dispatch(atom.views.getView(editor), 'lisp-paredit:expand-selection')
    atom.commands.dispatch(atom.views.getView(editor), 'core:copy')

# Pastes over current block of lisp code.
atom.commands.add 'atom-text-editor', 'jason:paste-sexp', ->
  editor = atom.workspace.getActiveTextEditor()
  atom.commands.dispatch(atom.views.getView(editor), 'lisp-paredit:up-sexp')
  atom.commands.dispatch(atom.views.getView(editor), 'lisp-paredit:expand-selection')
  atom.commands.dispatch(atom.views.getView(editor), 'core:paste')

# Deletes the current block of lisp code.
atom.commands.add 'atom-text-editor', 'jason:delete-sexp', ->
  editor = atom.workspace.getActiveTextEditor()
  atom.commands.dispatch(atom.views.getView(editor), 'lisp-paredit:up-sexp')
  atom.commands.dispatch(atom.views.getView(editor), 'lisp-paredit:expand-selection')
  atom.commands.dispatch(atom.views.getView(editor), 'core:delete')

wrap_in_rebl_submit = (code) ->
  "(let [value " + code + "] " +
    "(try" +
    "  ((requiring-resolve 'cognitect.rebl/submit) '" + code + " value)" +
    "  (catch Throwable _))" +
    " value)"

# This waits for the package to load
atom.packages.activatePackage('chlorine').then (pkg) ->
  # This picks up the "main module" of the package
  Cl = pkg.mainModule

  # Like Chlorine's evaluate-top-block, but sends it to REBL.
  atom.commands.add 'atom-text-editor', 'sean:inspect-top-block', ->
    result = Cl.ext.get_top_block()
    if result.text
      cmd = wrap_in_rebl_submit result.text
      Cl.ext.evaluate_and_present cmd, result.range

  # Like Chlorine's evaluate-block, but sends it to REBL.
  atom.commands.add 'atom-text-editor', 'sean:inspect-block', ->
    result = Cl.ext.get_block()
    if result.text
      cmd = wrap_in_rebl_submit result.text
      Cl.ext.evaluate_and_present cmd, result.range

  # Like Chlorine's evaluate-selection, but sends it to REBL.
  atom.commands.add 'atom-text-editor', 'sean:inspect-selection', ->
    result = Cl.ext.get_selection()
    if result.text
      cmd = wrap_in_rebl_submit result.text
      Cl.ext.evaluate_and_present cmd, result.range

  # Turn varname (expr) into a top-level def to make debugging easier.
  atom.commands.add 'atom-text-editor', 'sean:def-binding', ->
    result = Cl.ext.get_selection()
    if result.text
      cmd = wrap_in_rebl_submit("(def " + result.text + ")")
      Cl.ext.evaluate_and_present cmd, result.range

  # Send Var at cursor to REBL (as a Var so you can navigate it).
  atom.commands.add 'atom-text-editor', 'sean:inspect-var', ->
    result = Cl.ext.get_var()
    if result.text
      cmd = wrap_in_rebl_submit("#'" + result.text)
      Cl.ext.evaluate_and_present cmd, result.range

  # Inspect editor's current namespace in REBL (as a Var so you can navigate it).
  atom.commands.add 'atom-text-editor', 'sean:inspect-ns', ->
    result = Cl.ext.get_namespace()
    if result.text
      cmd = wrap_in_rebl_submit("(find-ns '" + result.text + ")")
      Cl.ext.evaluate_and_present cmd, result.range

  # Remove editor's current namespace (to recover from bad/changed aliases etc).
  atom.commands.add 'atom-text-editor', 'sean:remove-ns', ->
    result = Cl.ext.get_namespace()
    if result.text
      atom.notifications.addInfo("Removing...",{detail:result.text})
      cmd = "(remove-ns '" + result.text + ")"
      Cl.ext.evaluate_and_present cmd, result.range

  # Require with reload all the editor's current namespace.
  atom.commands.add 'atom-text-editor', 'sean:reload-ns-all', ->
    result = Cl.ext.get_namespace()
    if result.text
      atom.notifications.addInfo("Reloading all...",{detail:result.text})
      cmd = "(do (require '" + result.text + " :reload-all) " +
        "(println '" + result.text + " 'reloaded!))"
      Cl.ext.evaluate_and_present cmd, result.range

  # Pull up javadocs in REBL for selected code or symbol at cursor.
  atom.commands.add 'atom-text-editor', 'sean:inspect-java', ->
    result = Cl.ext.get_selection()
    if !result.text
      result = Cl.ext.get_var()
    if result.text
      cmd = wrap_in_rebl_submit(
        "(let [c-o-o " + result.text +
          "^Class c (if (instance? Class c-o-o) c-o-o (class c-o-o))] " +
            "(java.net.URL. " +
              "((requiring-resolve 'clojure.java.javadoc/javadoc-url) (.getName c))))"
      )
      Cl.ext.evaluate_and_present cmd, result.range

  # Pull ClojureDocs in REBL for symbol at cursor, if known.
  atom.commands.add 'atom-text-editor', 'sean:clojuredoc-var', ->
    result = Cl.ext.get_var()
    if result.text
      cmd = wrap_in_rebl_submit(
        "(java.net.URL. " +
          "(str \"http://clojuredocs.org/\" " +
            "(symbol #'" + result.text + ")))")
      Cl.ext.evaluate_and_present cmd, result.range
