
local strings = {}

strings.simple_d = '"a string"'
strings.simple_s = "'a simple single string'"
strings.simple_b = "`a simple backtick string`"
strings.esc_d = '"an \\" esc\\\'d double string "'
strings.esc_s = "' an \\\" esc\\\'d single string'"
strings.esc_h = "` an \\ esc\\\'d backtick \\\" string`"
strings.end_d = [["challenge double string\\\\"]]
strings.end_s = "'challenge single string\\\\'"
strings.end_h = "`challenge backtick string\\\\`"
strings.trivial_s = "''"
strings.trivial_d = '""'
strings.trivial_h = "``"

return strings