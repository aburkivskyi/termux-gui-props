#!@TERMUX_PREFIX@/bin/tgui-bash

set -o pipefail

declare props="/data/data/com.termux/files/home/.termux/termux.properties"

declare -A Switches=(
  [allow-external-apps]="false"
  [ctrl-space-workaround]="false"
  [disable-hardware-keyboard-shortcuts]="false"
  [disable-terminal-session-change-toast]="false"
  [enforce-char-based-input]="false"
  [extra-keys-text-all-caps]="false"
  [fullscreen]="false"
  [hide-soft-keyboard-on-startup]="false"
  [terminal-onclick-url-open]="false"
  [use-fullscreen-workaround]="false"
  [use-black-ui]="false"
)

declare APPLY="false"

read_props() {
	for key in "${!Switches[@]}"; do
	  Switches["$key"]="$(sed -n "/^$key/s/^.*= *//p" "$props")"
	done
	unset key
}

write_props() {
	for key in "${!Switches[@]}"; do
		sed -i "s/^$key.*/$key = ${Switches[$key]}/" "$props"
	done
	unset key
}


##########################################################


declare -A aparams=()
declare -a activity=()

tg_activity_new aparams activity

aid="${activity[0]}"

declare -A params=()

layout="$(tg_create_linear "$aid" params)"

# Create a Horizontal LinearLayout
params[$tgc_create_vertical]=false
bar="$(tg_create_linear "$aid" params "$layout")"
unset "params[$tgc_create_vertical]"

# Set the height no the minimum needed
tg_view_height "$aid" "$bar" "$tgc_view_wrap_content"
# Don't let it expand to unused space
tg_view_linear "$aid" "$bar" 0

# Create "Apply" Checkbox in the bar
params[$tgc_create_text]="apply"
params[$tgc_create_checked]="$APPLY"
apply="$(tg_create_checkbox "$aid" params "$bar")"
unset "params[$tgc_create_checked]"

# Create "Write" Button in the bar
params[$tgc_create_text]="Write"
bt_write="$(tg_create_button "$aid" params "$bar")"

unset "params[$tgc_create_text]"

# Create a NestedScrollView and a LinearLayout in it
sc="$(tg_create_nested_scroll "$aid" params "$layout")"
scl="$(tg_create_linear "$aid" params "$sc")"

# Create Switches in the NestedScrollView

read_props

# allow-external-apps
params[$tgc_create_text]="Allow external apps"
params[$tgc_create_checked]="${Switches["allow-external-apps"]}"
allow_external_apps="$(tg_create_switch "$aid" params "$scl")"

# ctrl-space-workaround
params[$tgc_create_text]="CTRL-Space workaround"
params[$tgc_create_checked]="${Switches["ctrl-space-workaround"]}"
ctrl_space_workaround="$(tg_create_switch "$aid" params "$scl")"

# disable-hardware-keyboard-shortcuts
params[$tgc_create_text]="Disable hardware keyboard shortcuts"
params[$tgc_create_checked]="${Switches["disable-hardware-keyboard-shortcuts"]}"
disable_hardware_keyboard_shortcuts="$(tg_create_switch "$aid" params "$scl")"

# disable-terminal-session-change-toast
params[$tgc_create_text]="Disable terminal session change toast"
params[$tgc_create_checked]="${Switches["disable-terminal-session-change-toast"]}"
disable_terminal_session_change_toast="$(tg_create_switch "$aid" params "$scl")"

# enforce-char-based-input
params[$tgc_create_text]="Enforce char-based input"
params[$tgc_create_checked]="${Switches["enforce-char-based-input"]}"
enforce_char_based_input="$(tg_create_switch "$aid" params "$scl")"

# extra-keys-text-all-caps
params[$tgc_create_text]="Extra-keys text all caps"
params[$tgc_create_checked]="${Switches["extra-keys-text-all-caps"]}"
extra_keys_text_all_caps="$(tg_create_switch "$aid" params "$scl")"

# fullscreen
params[$tgc_create_text]="Fullscreen"
params[$tgc_create_checked]="${Switches["fullscreen"]}"
fullscreen="$(tg_create_switch "$aid" params "$scl")"

# hide-soft-keyboard-on-startup
params[$tgc_create_text]="Hide soft keyboard on startup"
params[$tgc_create_checked]="${Switches["hide-soft-keyboard-on-startup"]}"
hide_soft_keyboard_on_startup="$(tg_create_switch "$aid" params "$scl")"

# terminal-onclick-url-open
params[$tgc_create_text]="On click url open"
params[$tgc_create_checked]="${Switches["terminal-onclick-url-open"]}"
terminal_onclick_url_open="$(tg_create_switch "$aid" params "$scl")"

# use-fullscreen-workaround
params[$tgc_create_text]="Use fullscreen workaround"
params[$tgc_create_checked]="${Switches["use-fullscreen-workaround"]}"
use_fullscreen_workaround="$(tg_create_switch "$aid" params "$scl")"

# use-black-ui
params[$tgc_create_text]="Use black UI"
params[$tgc_create_checked]="${Switches["use-black-ui"]}"
use_black_ui="$(tg_create_switch "$aid" params "$scl")"

unset "params[$tgc_create_text]" "params[$tgc_create_checked]"

while true; do
	ev="$(tg_msg_recv_event_blocking)"

	# Do when the "Apply" Checkbox is pressed
	if [[ "$(tg_event_type "$ev")" == "$tgc_ev_click" ]] \
		&& [[ "$(tg_event_aid "$ev")" == "$aid" ]] \
		&& [[ "$(tg_event_id "$ev")" == "$apply" ]]; then
		APPLY="$(jq -r '.value.set' <<<"$ev")"
  fi

	# Do when the button "Write" is pressed
	if [[ "$(tg_event_type "$ev")" == "$tgc_ev_click" ]] \
		&& [[ "$(tg_event_aid "$ev")" == "$aid" ]] \
		&& [[ "$(tg_event_id "$ev")" == "$bt_write" ]]; then
    write_props
		[[ "$APPLY" == "true" ]] && termux-reload-settings
  fi

	# Do when the switched [allow-external-apps]
	if [[ "$(tg_event_type "$ev")" == "$tgc_ev_click" ]] \
		&& [[ "$(tg_event_aid "$ev")" == "$aid" ]] \
		&& [[ "$(tg_event_id "$ev")" == "$allow_external_apps" ]]; then
		Switches[allow-external-apps]="$(jq -r '.value.set' <<<"$ev")"
	fi

	# Do when the switched [ctrl-space-workaround]
	if [[ "$(tg_event_type "$ev")" == "$tgc_ev_click" ]] \
		&& [[ "$(tg_event_aid "$ev")" == "$aid" ]] \
		&& [[ "$(tg_event_id "$ev")" == "$ctrl_space_workaround" ]]; then
		Switches[ctrl-space-workaround]="$(jq -r '.value.set' <<<"$ev")"
	fi

	# Do when the switched [disable-hardware-keyboard-shortcuts]
	if [[ "$(tg_event_type "$ev")" == "$tgc_ev_click" ]] \
		&& [[ "$(tg_event_aid "$ev")" == "$aid" ]] \
		&& [[ "$(tg_event_id "$ev")" == "$disable_hardware_keyboard_shortcuts" ]]; then
		Switches[disable-hardware-keyboard-shortcuts]="$(jq -r '.value.set' <<<"$ev")"
	fi

	# Do when the switched [disable-terminal-session-change-toast]
	if [[ "$(tg_event_type "$ev")" == "$tgc_ev_click" ]] \
		&& [[ "$(tg_event_aid "$ev")" == "$aid" ]] \
		&& [[ "$(tg_event_id "$ev")" == "$disable_terminal_session_change_toast" ]]; then
		Switches[disable-terminal-session-change-toast]="$(jq -r '.value.set' <<<"$ev")"
	fi

	# Do when the switched [enforce-char-based-input]
	if [[ "$(tg_event_type "$ev")" == "$tgc_ev_click" ]] \
		&& [[ "$(tg_event_aid "$ev")" == "$aid" ]] \
		&& [[ "$(tg_event_id "$ev")" == "$enforce_char_based_input" ]]; then
		Switches[enforce-char-based-input]="$(jq -r '.value.set' <<<"$ev")"
	fi

	# Do when the switched [extra-keys-text-all-caps]
	if [[ "$(tg_event_type "$ev")" == "$tgc_ev_click" ]] \
		&& [[ "$(tg_event_aid "$ev")" == "$aid" ]] \
		&& [[ "$(tg_event_id "$ev")" == "$extra_keys_text_all_caps" ]]; then
		Switches[extra-keys-text-all-caps]="$(jq -r '.value.set' <<<"$ev")"
	fi

	# Do when the switched [fullscreen]
	if [[ "$(tg_event_type "$ev")" == "$tgc_ev_click" ]] \
		&& [[ "$(tg_event_aid "$ev")" == "$aid" ]] \
		&& [[ "$(tg_event_id "$ev")" == "$fullscreen" ]]; then
		Switches[fullscreen]="$(jq -r '.value.set' <<<"$ev")"
	fi

	# Do when the switched [hide-soft-keyboard-on-startup]
	if [[ "$(tg_event_type "$ev")" == "$tgc_ev_click" ]] \
		&& [[ "$(tg_event_aid "$ev")" == "$aid" ]] \
		&& [[ "$(tg_event_id "$ev")" == "$hide_soft_keyboard_on_startup" ]]; then
		Switches[hide-soft-keyboard-on-startup]="$(jq -r '.value.set' <<<"$ev")"
	fi

	# Do when the switched [terminal-onclick-url-open]
	if [[ "$(tg_event_type "$ev")" == "$tgc_ev_click" ]] \
		&& [[ "$(tg_event_aid "$ev")" == "$aid" ]] \
		&& [[ "$(tg_event_id "$ev")" == "$terminal_onclick_url_open" ]]; then
		Switches[terminal-onclick-url-open]="$(jq -r '.value.set' <<<"$ev")"
	fi

	# Do when the switched [use-fullscreen-workaround]
	if [[ "$(tg_event_type "$ev")" == "$tgc_ev_click" ]] \
		&& [[ "$(tg_event_aid "$ev")" == "$aid" ]] \
		&& [[ "$(tg_event_id "$ev")" == "$use_fullscreen_workaround" ]]; then
		Switches[use-fullscreen-workaround]="$(jq -r '.value.set' <<<"$ev")"
	fi

	# Do when the switched [use-black-ui]
	if [[ "$(tg_event_type "$ev")" == "$tgc_ev_click" ]] \
		&& [[ "$(tg_event_aid "$ev")" == "$aid" ]] \
		&& [[ "$(tg_event_id "$ev")" == "$use_black_ui" ]]; then
		Switches[use-black-ui]="$(jq -r '.value.set' <<<"$ev")"
	fi

	if [[ "$(tg_event_type "$ev")" == "$tgc_ev_destroy" ]]; then
    exit 0
  fi
done

# vim: ft=bash ts=2 sts=2 sw=2
