(ns sample
  (:gen-class))

(defn main
  [& args]
  (println "Hello from the test project!"))

(defn -main
  [& args]
  (apply main args))
