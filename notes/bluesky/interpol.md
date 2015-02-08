#interpol

Man, I really need an actual wiki. This is getting unmanageable.

interpol is a short command line utility I could write in Rust. It takes stdin, a line at a time, and interpolates the result (without newline) into the specified file. By default the template is `{}` but this may be specified on the command line. 

Returns zero if it interpolated into all templates, minus if it received EOF before filling all templates, and plus if it continuted to receive input after filling all templates. Overflow is written to stderr. 

I think this would be fun to write. It's a distraction at the moment.

flags:

-f specify a stdin

-x exit when the last template fills, regardless of status of stdin

-h of course

-t provide a template as a C-style quoted string.