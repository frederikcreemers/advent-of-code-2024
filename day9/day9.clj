(ns my-script.core)

(defn file-checksum [start-idx block-size block-idx]
  (let [result (reduce + (map (fn [n] (* n block-idx)) (range start-idx (+ start-idx block-size))))]
    result
  )
)

(defn compact-and-checksum
  ([numbers] (compact-and-checksum numbers 0 0))
  ([init-numbers init-starting-memindex init-starting-fileindex]
   (loop [numbers init-numbers
          starting-memindex init-starting-memindex
          starting-fileindex init-starting-fileindex
          acc 0]
          ;(println "DEBUG: called with" numbers starting-memindex starting-fileindex, "nnumbers", (count numbers))
          (cond
     ;; Case 1: Two numbers remaining
     (== (count numbers) 2)
     (+ acc (file-checksum starting-memindex (peek numbers) (+ starting-fileindex 1)))

     ;; Case 2: Odd number of numbers
     (== (mod (count numbers) 2) 1)
     (let [first-file-checksum (file-checksum starting-memindex (first numbers) starting-fileindex)]
        (recur (vec (rest numbers)) (+ starting-memindex (first numbers)) starting-fileindex (+ acc first-file-checksum)))

     ;; Case 3: Default (even numbers)
     :else
     (let [available-block-size (first numbers)
           last-file-size (peek numbers)
           last-file-index (+ starting-fileindex (int (/ (count numbers) 2)))
           filled-space-size (min available-block-size last-file-size)
           filled-space-checksum (file-checksum starting-memindex filled-space-size last-file-index)]
       (if (< available-block-size last-file-size)
         (let [new-numbers (rest (assoc numbers (- (count numbers) 1) (- last-file-size available-block-size)))]
            (recur new-numbers (+ starting-memindex filled-space-size) (+ starting-fileindex 1) (+ acc filled-space-checksum)))
         (let [remaining-block-size (- available-block-size last-file-size)
               new-numbers (pop (pop (assoc numbers 0 remaining-block-size)))]
            (recur new-numbers (+ starting-memindex filled-space-size) starting-fileindex (+ acc filled-space-checksum)))))))))

(defn part1 [numbers]
  (compact-and-checksum numbers)
)

(defn find-first-index [predicate vect]
  (first (keep-indexed (fn [idx val] (when (predicate val) idx)) vect)))

(defn insert-at-index [v i e] (vec (concat (take i v) [e] (drop i v))))

(defn move-into-sector [sectors file-sector space-index]
  (let [space-sector (nth sectors space-index)
        updated-sector (assoc file-sector 0 "moved-file")
        replaced-sectors (assoc sectors space-index updated-sector)
        remaining-space (- (nth space-sector 1) (nth file-sector 1))]
    (if (> remaining-space 0)
        (insert-at-index replaced-sectors (+ space-index 1) ["space" remaining-space])
        replaced-sectors
    )
  )
)

(defn checksum-compacted-files [sectors]
  (loop [sectors sectors blockidx 0 acc 0]
    (if (== (count sectors) 0)
        acc
        (let [sector (first sectors)
              sector-size (nth sector 1)
              next-blockidx (+ blockidx sector-size)]
            (if (or (= "file" (first sector)) (= "moved-file" (first sector)))
                (recur (vec (rest sectors)) next-blockidx (+ acc (file-checksum blockidx sector-size (nth sector 2))))
                (recur (vec (rest sectors)) next-blockidx acc)
            )
        )
    )
  )
)

(defn compact-whole-files [sectors]
  (loop [sectors sectors suffix []]
    (let [last-sector (peek sectors)]
      (cond
        (== (count sectors) 1)
          (into sectors suffix)
        (= "file" (first last-sector))
        (let [available-space-index (find-first-index (fn [x]
            (and (= "space" (first x)) 
            (>= (nth x 1) (nth last-sector 1))
        )) sectors)]
            (if available-space-index
                (let [new-sectors (move-into-sector sectors last-sector available-space-index)]
                    (recur (pop new-sectors ) (into [[:space (nth last-sector 1)]] suffix))
                )
                (recur (pop sectors) (into [last-sector] suffix))
            )
        )
        (or (= "space" (first last-sector)) (= "moved-file" (first last-sector)))
        (recur (pop sectors) (into [last-sector] suffix))
      )
    )
  )
)


(defn part2 [numbers]
  (checksum-compacted-files (compact-whole-files (vec (map (fn [n, index] (
    if (== (mod index 2) 1)
        ["space" n]
        ["file" n (int (/ index 2))]
  )) numbers (range 0 (count numbers))))))
)

(defn -main [& args]
  (let [contents (slurp "input.txt")
        numbers (into [] (map (fn [^Character c] (Character/digit c 10)) contents))
        ]
    (println "Part 1:" (part1 numbers))
    (println "Part 2:" (part2 numbers))
))

(-main)