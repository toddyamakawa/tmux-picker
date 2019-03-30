#!/usr/bin/env bash
exec /arm/tools/setup/bin/mrun +ruby/ruby/2.5.1 ruby $0 "$@"
#!/usr/bin/env ruby

# Return last pane_id
def tmux_last_pane_id
	`tmux display-message -p -t '{last}' '\#{pane_id}'`.chomp
end


# Return [pane_id, height, position, moode]
def tmux_current_pane_info
	vars = %w(pane_id pane_height scroll_position ?pane_in_mode,1,0)
	`tmux display-message -p "#{vars.map{ |v| "\#{#{v}}" }.join(':')}"`.chomp.split(':')
end


# Return file of captured pane
def tmux_capture_pane
	id, height, pos, mode = tmux_current_pane_info()

	# Calculate start/end pos
	if mode == '1'
		start_pos = -pos
		end_pos = height - pos - 1
	else
		start_pos = 0
		end_pos = '-'
	end

	# REVISIT: Use Ruby tempfile library
	file = `mktemp`.chomp
	File.write(file, `tmux capture-pane -p -e -J -t #{id} -S #{start_pos} -E #{end_pos}`)
	return id, file
end


# TODO: Implement picker pane
def picker_pane(cmd)
	p cmd
	`tmux new-window -P -F "\#{window_id}:\#{pane_id}" -d -n "[picker]" #{cmd}`.chomp
end


if __FILE__ == $0
	here = File.dirname(File.realpath($0))
	last_pane_id = tmux_last_pane_id
	current_pane_id, capture_file = tmux_capture_pane
	p picker_pane("#{here}/hint_mode.rb #{capture_file} #{current_pane_id} #{last_pane_id}")
end

