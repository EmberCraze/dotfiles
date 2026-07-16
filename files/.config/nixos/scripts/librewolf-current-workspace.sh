set -euo pipefail

url="${1:-}"
log_file="${XDG_CACHE_HOME:-$HOME/.cache}/librewolf-current-workspace.log"

log() {
  printf '%s %s\n' "$(date --iso-8601=seconds)" "$*" >> "$log_file"
}

log "open url=$url"

focused_window_id="$(
  niri msg -j windows \
    | jq -r '.[] | select(.is_focused == true) | .id'
)"
log "focused_window_id=$focused_window_id"

focused_workspace_id="$(
  niri msg -j workspaces \
    | jq -r '.[] | select(.is_focused == true) | .id'
)"
log "focused_workspace_id=$focused_workspace_id"

librewolf_window_id="$(
  niri msg -j windows \
    | jq -r --argjson ws "$focused_workspace_id" '
        .[]
        | select(.workspace_id == $ws)
        | select(.app_id == "librewolf" or .app_id == "LibreWolf")
        | .id
      ' \
    | head -n1
)"
log "librewolf_window_id=$librewolf_window_id"

if [ -n "$librewolf_window_id" ]; then
  log "action=reuse-window id=$librewolf_window_id"
  niri msg action focus-window --id "$librewolf_window_id"
  librewolf --new-tab "$url" >/dev/null 2>&1 &
  sleep 0.2

  if [ -n "$focused_window_id" ] && [ "$focused_window_id" != "$librewolf_window_id" ]; then
    log "action=restore-focus id=$focused_window_id"
    niri msg action focus-window --id "$focused_window_id" || true
  fi
else
  log "action=new-window"
  librewolf --new-window "$url" >/dev/null 2>&1 &
fi
