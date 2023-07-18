#!/usr/bin/env bash

PLUGIN_DIR="$(tmux show-env -g TMUX_PLUGIN_MANAGER_PATH | cut -f2 -d=)"

get_tmux_option() {
  local option value default
  option="$1"
  default="$2"
  value="$(tmux show-option -gqv "$option")"

  if [ -n "$value" ]; then
    echo "$value"
  else
    echo "$default"
  fi
}

if_in_array_else() {
	local options
	local option value default found
	option="$1"
	value="$2"
	default="$3"
	shift 3
	options=("$@")
	found="1"

	for v in "${options[@]}"; do
		if [[ "$v" = "$option" ]]; then
			found="0"
		fi
	done

	if [[ "$found" = "1" ]]; then
		echo "$default"
	else
		echo "$value"
	fi
}

main() {
	local day_themes=("day" "light" "tomorrow")
	local modifier_theme_names=("blue" "bright" "eighties")
	local night_themes=("blue" "bright" "dark" "eighties" "night")
	local eighties_themes=("blue" "eighties")
	local theme
	theme="$(get_tmux_option "@tomorrow_theme" "night")"
	readonly theme

	local theme_name
	theme_name=tomorrow

	theme_name="$( if_in_array_else "$theme" "$theme_name-night" $theme_name "${night_themes[@]}" )"
	theme_name="$( if_in_array_else "$theme" "$theme_name-eighties" $theme_name "${eighties_themes[@]}" )"
	theme_name="$( if_in_array_else "$theme" "$theme_name-${theme}" $theme_name "${modifier_theme_names[@]}" )"
	theme_name="$( if_in_array_else "$theme" "tomorrow.tmuxtheme" "$theme_name.tmuxtheme" "${day_themes[@]}" )"


	local theme_path
	theme_path="${PLUGIN_DIR}tmux-tomorrow/$theme_name"

	echo "$theme"
	if [ -f $theme_path ]; then
	  tmux source-file $theme_path
	fi
}

main "$@"
