local ref = function(idx)
	local bound = function(argnode_text)
		return argnode_text[idx]
	end

	return f(bound, { idx })
end

return {
	s({ trig = "range" }, fmta([[
		for <>, <> := range <> {
			<>
		}
	]], {i(1, "i"), i(2, "val"), i(3), i(0)})),

	s({ trig = "ife" }, fmta([[
			if <> != nil {
				return <>
			}
		]], { i(1, "err"), ref(1) })),
}
