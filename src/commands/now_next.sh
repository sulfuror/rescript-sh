function now_next {
  case "$unix_name" in
    Linux|GNU)
      now=$(date +"%s")
      ;;
    *)
      now=$(gdate +"%s" 2>/dev/null || date +"%s")
      ;;
  esac
  next=$(cat "$config_dir/$repo-datefile" 2>/dev/null || echo "0")
  if ! [[ "$next" =~ ^[0-9]+$ ]] ; then
    next=0
  fi
}

