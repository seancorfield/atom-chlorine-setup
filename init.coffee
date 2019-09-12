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

EditorUtils = require("./packages/chlorine/lib/editor-utils")

wrapped_eval = (ranger, selector, wrapper) ->
  editor = atom.workspace.getActiveTextEditor()
  chlorine = atom.packages.getLoadedPackage('chlorine').mainModule
  range = ranger(editor)
  chlorine.repl.eval_and_present(
    editor,
    EditorUtils.findNsDeclaration(editor),
    editor.getPath(),
    range,
    wrapper(selector(editor,range))
  )

# Like Chlorine's evaluate-top-block, but sends it to REBL.
atom.commands.add 'atom-text-editor', 'sean:inspect-top-block', ->
  wrapped_eval(
    (editor) -> EditorUtils.getCursorInBlockRange(editor,{topLevel:true}),
    (editor,range) -> editor.getTextInBufferRange(range),
    (code) -> wrap_in_rebl_submit(code)
  )

# Like Chlorine's evaluate-block, but sends it to REBL.
atom.commands.add 'atom-text-editor', 'sean:inspect-block', ->
  wrapped_eval(
    (editor) -> EditorUtils.getCursorInBlockRange(editor),
    (editor,range) -> editor.getTextInBufferRange(range),
    (code) -> wrap_in_rebl_submit(code)
  )

# Like Chlorine's evaluate-selection, but sends it to REBL.
atom.commands.add 'atom-text-editor', 'sean:inspect-selection', ->
  wrapped_eval(
    (editor) -> editor.getSelectedBufferRange(),
    (editor,_) -> editor.getSelectedText(),
    (code) -> wrap_in_rebl_submit(code)
  )

# Turn varname (expr) into a top-level def to make debugging easier.
atom.commands.add 'atom-text-editor', 'sean:def-binding', ->
  wrapped_eval(
    (editor) -> editor.getSelectedBufferRange(),
    (editor,_) -> editor.getSelectedText(),
    (code) -> wrap_in_rebl_submit("(def " + code + ")")
  )

# Send Var at cursor to REBL (as a Var so you can navigate it).
atom.commands.add 'atom-text-editor', 'sean:inspect-var', ->
  wrapped_eval(
    (editor) -> editor.getSelectedBufferRange(),
    (editor,_) -> EditorUtils.getClojureVarUnderCursor(editor),
    (code) -> wrap_in_rebl_submit("#'" + code)
  )

# Inspect editor's current namespace in REBL (as a Var so you can navigate it).
atom.commands.add 'atom-text-editor', 'sean:inspect-ns', ->
  wrapped_eval(
    (editor) -> editor.getSelectedBufferRange(),
    (editor,_) -> EditorUtils.findNsDeclaration(editor),
    (code) -> wrap_in_rebl_submit("(find-ns '" + code + ")")
  )

# Pull up javadocs in REBL for selected code or symbol at cursor.
atom.commands.add 'atom-text-editor', 'sean:inspect-java', ->
  wrapped_eval(
    (editor) -> editor.getSelectedBufferRange(),
    (editor,_) -> editor.getSelectedText() || EditorUtils.getClojureVarUnderCursor(editor),
    (code) -> wrap_in_rebl_submit(
      "(let [c-o-o " + code +
        "^Class c (if (instance? Class c-o-o) c-o-o (class c-o-o))] " +
          "(java.net.URL. " +
            "((requiring-resolve 'clojure.java.javadoc/javadoc-url) (.getName c))))"
    )
  )
