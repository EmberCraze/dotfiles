set -euo pipefail

url="${1:-}"
log_file="${XDG_CACHE_HOME:-$HOME/.cache}/brave-current-workspace.log"

log() {
  printf '%s %s\n' "$(date --iso-8601=seconds)" "$*" >> "$log_file"
}

log "open url=$url"

focused_workspace_id="$(
  niri msg -j workspaces \
    | jq -r '.[] | select(.is_focused == true) | .id'
)"
log "focused_workspace_id=$focused_workspace_id"

brave_window_id="$(
  niri msg -j windows \
    | jq -r --argjson ws "$focused_workspace_id" '
        .[]
        | select(.workspace_id == $ws)
        | select(.app_id == "brave-browser" or .app_id == "Brave-browser")
        | .id
      ' \
    | head -n1
)"
log "brave_window_id=$brave_window_id"

if [ -n "$brave_window_id" ]; then
  log "action=reuse-window id=$brave_window_id"
  niri msg action focus-window --id "$brave_window_id"
  # Wait until Brave has actually received focus, otherwise it opens the URL
  # in its previously active window instead of this one.
  for _ in $(seq 1 20); do
    focused_window_id="$(niri msg -j windows | jq -r '.[] | select(.is_focused == true) | .id')"
    [ "$focused_window_id" = "$brave_window_id" ] && break
    sleep 0.05
  done
  sleep 0.1
  brave "$url" >/dev/null 2>&1 &
else
  log "action=new-window"
  brave --new-window "$url" >/dev/null 2>&1 &
fi
