local P = "ctrl+space" -- tmux-style prefix (leader)

rex.bind("cmd+a", "pane.send_key", { key = "alt+a" })
rex.bind("cmd+s", "pane.send_key", { key = "alt+s" })
rex.bind("cmd+d", "pane.send_key", { key = "alt+d" })

rex.bind(P .. ">shift+5", "pane.split", { direction = "right" }) -- %
rex.bind(P .. ">shift+'", "pane.split", { direction = "down" }) -- "
rex.bind(P .. ">v", "pane.split", { direction = "down" })

rex.action({
	name = "focus_pane",
	title = "Focus Pane in Direction",
	category = "Panes",
	args = { direction = "string" },
	run = function(ctx, args)
		local _, err = rex.session.focus_direction({
			block_id = ctx.block_id,
			direction = args.direction,
		})
		if err ~= nil then
			error(err, 0)
		end
	end,
})

rex.action({
	name = "focus_next_pane",
	title = "Focus Next Pane",
	category = "Panes",
	run = function(ctx, args)
		local _, err = rex.session.focus_next_pane({})
		if err ~= nil then
			error(err, 0)
		end
	end,
})

rex.bind(P .. ">h", "focus_pane", { direction = "left" })
rex.bind(P .. ">j", "focus_pane", { direction = "down" })
rex.bind(P .. ">k", "focus_pane", { direction = "up" })
rex.bind(P .. ">l", "focus_pane", { direction = "right" })
rex.bind(P .. ">o", "focus_next_pane")

rex.bind(P .. ">z", "pane.zoom")
rex.bind(P .. ">x", "pane.close")
-- Ghostty's equalize_splits (prefix + =) has no documented Rex equivalent yet.

rex.bind(P .. ">c", "client.tab.new")
rex.bind(P .. ">n", "client.tab.next")
rex.bind(P .. ">p", "client.tab.previous")
for i = 1, 9 do
	rex.bind(P .. ">" .. i, "client.tab.goto", { index = i })
end

rex.bind(P .. ">" .. P, "pane.send_key", { key = "ctrl+space" })
