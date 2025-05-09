return {
	parse("BOSL", "include <BOSL2/std.scad>\n\n$$fn = $$preview ? 32 : 128;"),

	-- https://github.com/BelfrySCAD/BOSL2/wiki/attachments.scad#module-attachable
	parse(
		"new attachable",
		[[module ${1:name}(anchor=CENTER, orient=UP, spin=0) {
	attachable(anchor, spin, orient, ...) {
		children();
	}
}]]
	),
}
