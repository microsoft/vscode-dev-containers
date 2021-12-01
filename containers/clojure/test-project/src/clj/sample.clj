(ns sample
  (:gen-class))

(defn main
  [& args]
  (println "Hello world"))

(defn -main
  [& args]
  (apply main args))
