;; Injection queries for Gherkin doc strings
;; These queries enable syntax highlighting for code blocks within doc strings
;; based on the specified content type

;; Inject any specified language from doc string content type
((doc_string
   content_type: (_) @injection.language
   content: (_) @injection.content)
 (#not-eq? @injection.language ""))
