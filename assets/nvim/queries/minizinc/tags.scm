; https://github.com/shackle-rs/shackle/blob/develop/parsers/tree-sitter-minizinc/queries/tags.scm
(function_item name: (identifier) @name) @definition.function
(predicate name: (identifier) @name) @definition.function
(annotation name: (identifier) @name) @definition.function

(call function: (identifier) @name) @reference.call
