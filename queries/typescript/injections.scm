(call_expression
    (comment) @comment
    (#match? @comment "^/\\*\\s*sql\\s*\\*/$")
    .
    (template_string 
        (string_fragment) @injection.content)
    (#set! injection.language "sql"))
