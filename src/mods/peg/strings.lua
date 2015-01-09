
local strings = {}

strings.simple_d = '"a simple double string"'
strings.simple_s = "'a simple single string'"
strings.simple_b = "`a simple backtick string`"
strings.esc_d = '"an \" esc\'d double string "'
strings.esc_s = "' an \" esc\'d single string'"
strings.esc_h = "` an \` esc\'d backtick \" string"
string.end_d = '"challenge double string\\"'
string.end_s = "'challenge single string\\'"
string.end_h = "'challenge backtick string\\`"

return strings