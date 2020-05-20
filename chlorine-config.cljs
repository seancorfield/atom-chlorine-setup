;; experimental versions of my init.coffee functions

(defn- wrap-in-rebl-submit [code]
  (str "(let [value " code "] "
       "(try"
       "  ((requiring-resolve 'cognitect.rebl/submit) '" code " value)"
       "  (catch Throwable _))"
       " value)"))

(defn rebl-top-block []
  (let [block (editor/get-top-block)]
    (when block
      (-> block
          (update :text wrap-in-rebl-submit)
          (editor/eval-and-render)))))

(defn rebl-block []
  (let [block (editor/get-block)]
    (when block
      (-> block
          (update :text wrap-in-rebl-submit)
          (editor/eval-and-render)))))

(defn rebl-selection []
  (let [block (editor/get-selection)]
    (when block
      (-> block
          ;; debugging:
          (assoc :text (str block))
          (update :text wrap-in-rebl-submit)
          (editor/eval-and-render)))))

(defn rebl-def-var []
  (let [block (editor/get-selection)]
    (when block
      (-> block
          (update :text
                  #(str "(def " % ")"))
          (update :text wrap-in-rebl-submit)
          (editor/eval-and-render)))))

(defn rebl-var []
  (let [block (editor/get-var)]
    (when block
      (-> block
          (update :text #(str "#'" %))
          (update :text wrap-in-rebl-submit)
          (editor/eval-and-render)))))

(defn rebl-ns []
  (let [block (editor/get-namespace)]
    (when block
      (-> block
          (update :text #(str "(find-ns '" % ")"))
          (update :text wrap-in-rebl-submit)
          (editor/eval-and-render)))))

(defn rebl-remove-ns []
  (let [block (editor/get-namespace)]
    (when block
      (-> block
          (update :text
                  #(str
                    "(do (println 'Removing '" % "\"...\")"
                    " (remove-ns '" % "))"))
          (update :text wrap-in-rebl-submit)
          (editor/eval-and-render)))))

(defn rebl-reload-all-ns []
  (let [block (editor/get-namespace)]
    (when block
      (-> block
          (update :text
                  #(str
                    "(do (println 'Reloading '" % "\"...\")"
                    " (require '" % " :reload-all)"
                    " (println \"...\" '" % " 'reloaded))"))
          (update :text wrap-in-rebl-submit)
          (editor/eval-and-render)))))

(defn rebl-doc-var []
  (let [block (editor/get-var)]
    (when block
      (-> block
          (update :text
                  #(str
                    "(java.net.URL. "
                    "(str \"http://clojuredocs.org/\" "
                    "(symbol #'" % ")))"))
          (update :text wrap-in-rebl-submit)
          (editor/eval-and-render)))))

(defn rebl-javadoc []
  ;; this should be either selection or var
  (let [block (editor/get-var)]
    (when block
      (-> block
          (update :text
                  #(str
                    "(let [c-o-o " %
                    " ^Class c (if (instance? Class c-o-o) c-o-o (class c-o-o))] "
                    "(java.net.URL. "
                    "((requiring-resolve 'clojure.java.javadoc/javadoc-url) (.getName c))))"))
          (update :text wrap-in-rebl-submit)
          (editor/eval-and-render)))))
