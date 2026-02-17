#!/bin/zsh
# Tree-style git status for all repos under Dev/projects

green='\033[0;32m'
yellow='\033[1;33m'
dim='\033[2m'
nc='\033[0m'
projects_dir="$HOME/Dev/projects"

typeset -a grps subs counts dirties
typeset -A seen
typeset -a uniq_grps
total=0 ndirty=0

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

# Tree
ng=${#uniq_grps[@]}
for gi in {1..$ng}; do
  grp="${uniq_grps[$gi]}"
  gc="├─"; gp="│    "
  [[ $gi -eq $ng ]] && gc="└─" && gp="     "

  # Reset per-group arrays
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
