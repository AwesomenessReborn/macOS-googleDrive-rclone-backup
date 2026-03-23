#!/bin/zsh
# Tree-style git status for all repos under Dev/projects

green='\033[0;32m'
yellow='\033[1;33m'
dim='\033[2m'
nc='\033[0m'
projects_dir="$HOME/Dev/projects"
extra_repos=("$HOME/Dev/backup-framework")

typeset -a grps subs counts dirties
typeset -A seen
typeset -a uniq_grps
total=0 ndirty=0

# Extra repos: collect separately
typeset -a ex_names ex_counts ex_dirties
for er in "${extra_repos[@]}"; do
  [[ -d "$er/.git" ]] || continue
  (( total++ ))
  ch="$(git -C "$er" status --short 2>/dev/null)"
  ct=0; d=0
  if [[ -n "$ch" ]]; then
    ct=$(printf '%s\n' "$ch" | wc -l | tr -d ' ')
    d=1; (( ndirty++ ))
  fi
  ex_names+=("${er:t}"); ex_counts+=("$ct"); ex_dirties+=("$d")
done

# Projects tree repos
for gd in "${(@f)$(find "$projects_dir" -maxdepth 4 -name ".git" -type d 2>/dev/null)}"; do
  (( total++ ))
  rp="${gd%/.git}"
  sh="${rp#$projects_dir/}"

  if [[ "$sh" == */* ]]; then
    grp="${sh%%/*}"; sub="${sh#*/}"
  else
    grp="$sh"; sub="."
  fi

  ch="$(git -C "$rp" status --short 2>/dev/null)"
  ct=0; d=0
  if [[ -n "$ch" ]]; then
    ct=$(printf '%s\n' "$ch" | wc -l | tr -d ' ')
    d=1; (( ndirty++ ))
  fi

  grps+=("$grp"); subs+=("$sub"); counts+=("$ct"); dirties+=("$d")
  if [[ -z "${seen[$grp]+x}" ]]; then uniq_grps+=("$grp"); seen[$grp]=1; fi
done

# Header
if [[ $ndirty -eq 0 ]]; then
  print -P "  ${green} git${nc}  all clean  ${dim}—  ${total} repos${nc}"
else
  print -P "  ${yellow} git${nc}  ${ndirty} dirty  ${dim}—  ${total} repos${nc}"
fi
[[ $total -eq 0 ]] && exit

# Tree — groups from projects_dir
ng=${#uniq_grps[@]}
nex=${#ex_names[@]}
for gi in {1..$ng}; do
  grp="${uniq_grps[$gi]}"
  # Use └─ only if this is the last group AND there are no extra repos after
  last_group=$(( gi == ng && nex == 0 ))
  gc="├─"; gp="│    "
  [[ $last_group -eq 1 ]] && gc="└─" && gp="     "

  rs=(); rc=(); rd=()
  for ri in {1..${#grps[@]}}; do
    if [[ "${grps[$ri]}" == "$grp" ]]; then
      rs+=("${subs[$ri]}"); rc+=("${counts[$ri]}"); rd+=("${dirties[$ri]}")
    fi
  done

  print -P "  ${dim}${gc}${nc} ${grp}/"

  nr=${#rs[@]}
  for ri in {1..$nr}; do
    sym="├─"; [[ $ri -eq $nr ]] && sym="└─"
    name="${rs[$ri]}"; [[ "$name" == "." ]] && name="$grp"
    if [[ "${rd[$ri]}" -eq 1 ]]; then
      print -P "  ${dim}${gp}${sym}${nc} ${yellow}${name}${nc}  ${dim}(${rc[$ri]} changed)${nc}"
    else
      print -P "  ${dim}${gp}${sym} ${green}✓${nc}  ${dim}${name}${nc}"
    fi
  done
done

# Extra repos — listed directly at root level
for ei in {1..$nex}; do
  sym="└─"; [[ $ei -lt $nex ]] && sym="├─"
  name="${ex_names[$ei]}"
  if [[ "${ex_dirties[$ei]}" -eq 1 ]]; then
    print -P "  ${dim}${sym}${nc} ${yellow}${name}${nc}  ${dim}(${ex_counts[$ei]} changed)${nc}"
  else
    print -P "  ${dim}${sym} ${green}✓${nc}  ${dim}${name}${nc}"
  fi
done
