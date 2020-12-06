;; ~/.atom/chlorine-config.cljs

(defn- wrap-in-tap [code]
  (str "(let [value " code
       "      rr      (try (resolve 'requiring-resolve) (catch Throwable _))]"
       "  (if-let [rs (try (rr 'cognitect.rebl/submit) (catch Throwable _))]"
       "    (rs '" code " value)"
       "    (tap> value))"
       "  value)"))

(defn tap-top-block []
  (p/let [block (editor/get-top-block)]
    (when (seq (:text block))
      (-> block
          (update :text wrap-in-tap)
          (editor/eval-and-render)))))

(defn tap-block []
  (p/let [block (editor/get-block)]
    (when (seq (:text block))
      (-> block
          (update :text wrap-in-tap)
          (editor/eval-and-render)))))

(defn tap-selection []
  (p/let [block (editor/get-selection)]
    (when (seq (:text block))
      (-> block
          (update :text wrap-in-tap)
          (editor/eval-and-render)))))

(defn tap-def-var []
  (p/let [block (editor/get-selection)]
    (when (seq (:text block))
      (-> block
          (update :text
                  #(str "(def " % ")"))
          (update :text wrap-in-tap)
          (editor/eval-and-render)))))

(defn tap-var []
  (p/let [block (editor/get-var)]
    (when (seq (:text block))
      (-> block
          (update :text #(str "(or (find-ns '" % ") (resolve '" % "))"))
          (update :text wrap-in-tap)
          (editor/eval-and-render)))))

(defn tap-ns []
  (p/let [block (editor/get-namespace)
          here  (editor/get-selection)]
    (when (seq (:text block))
      (-> block
          (update :text #(str "(find-ns '" % ")"))
          (update :text wrap-in-tap)
          (assoc :range (:range here))
          (editor/eval-and-render)))))

(defn tap-remove-ns []
  (p/let [block (editor/get-namespace)
          here  (editor/get-selection)]
    (when (seq (:text block))
      (editor/run-callback
       :notify
       {:type :info :title "Removing..." :message (:text block)})
      (-> block
          (update :text #(str "(remove-ns '" % ")"))
          (update :text wrap-in-tap)
          (assoc :range (:range here))
          (editor/eval-and-render)))))

(defn tap-reload-all-ns []
  (p/let [block (editor/get-namespace)
          here  (editor/get-selection)]
    (when (seq (:text block))
      (editor/run-callback
       :notify
       {:type :info :title "Reloading all..." :message (:text block)})
      (p/let [res (editor/eval-and-render
                    (-> block
                        (update :text #(str "(require '" % " :reload-all)"))
                        (update :text wrap-in-tap)
                        (assoc :range (:range here))))]
        (editor/run-callback
         :notify
         {:type (if (:error res) :warn :info)
          :title (if (:error res)
                   "Reload failed for..."
                   "Reload succeeded!")
          :message (:text block)})))))

(defn- format-test-result [{:keys [test pass fail error]}]
  (str "Ran " test " test"
       (when-not (= 1 test) "s")
       (when-not (zero? pass)
         (str ", " pass " assertion"
              (when-not (= 1 pass) "s")
              " passed"))
       (when-not (zero? fail)
         (str ", " fail " failed"))
       (when-not (zero? error)
         (str ", " error " errored"))
       "."))

(defn tap-run-side-tests []
  (p/let [block (editor/get-namespace)
          here  (editor/get-selection)]
    (when (seq (:text block))
      (p/let [res (editor/eval-and-render
                    (-> block
                        (update :text (fn [s] (str "
                          (some #(try
                                   (let [nt (symbol (str \"" s "\" \"-\" %))]
                                     (require nt)
                                     (clojure.test/run-tests nt))
                                  (catch Throwable _))
                                [\"test\" \"expectations\"])")))
                        (update :text wrap-in-tap)
                        (assoc :range (:range here))))]
        (editor/run-callback
         :notify
         {:type (if (:error res) :warn :info)
          :title (if (:error res)
                   "Failed to run tests for..."
                   "Tests completed!")
          :message (if (:error res) (:text block) (format-test-result (:result res)))})))))

(defn tap-doc-var []
  (p/let [block (editor/get-var)]
    (when (seq (:text block))
      (-> block
          (update :text
                  #(str
                    "(java.net.URL."
                    " (str \"http://clojuredocs.org/\""
                    " (-> (str (symbol #'" % "))"
                    ;; clean up ? ! &
                    "  (clojure.string/replace \"?\" \"%3f\")"
                    "  (clojure.string/replace \"!\" \"%21\")"
                    "  (clojure.string/replace \"&\" \"%26\")"
                    ")))"))
          (update :text wrap-in-tap)
          (editor/eval-and-render)))))

(defn tap-javadoc []
  (p/let [block (editor/get-selection)
          block (if (< 1 (count (:text block))) block (editor/get-var))]
      (when (seq (:text block))
        (-> block
            (update :text
                    #(str
                      "(let [c-o-o " %
                      " ^Class c (if (instance? Class c-o-o) c-o-o (class c-o-o))] "
                      " (java.net.URL. "
                      "  (clojure.string/replace"
                      "   ((requiring-resolve 'clojure.java.javadoc/javadoc-url)"
                      "    (.getName c))"
                      ;; strip inner class
                      "   #\"\\$[a-zA-Z0-9_]+\" \"\""
                      ")))"))
            (update :text wrap-in-tap)
            (editor/eval-and-render)))))
