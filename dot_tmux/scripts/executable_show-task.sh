#!/bin/bash
max_tasks=2
tasks=$(task rc.verbose: ls limit:$max_tasks)
n_tasks=$(echo "$tasks" | wc -l)
if [ $n_tasks -eq 0 ]; then
  echo "No Tasks"
else
  results=()
  for i in $(seq 1 $n_tasks); do
    task=$(echo "$tasks" | sed -n "${i}p" | cut -d' ' -f3)
    trimmed_task=$(echo "$task" | cut -c1-12)
    if [ "$task" != "$trimmed_task" ]; then
      trimmed_task="$trimmed_task.."
    fi
    results+=("$trimmed_task")
  done
  (
    IFS=$"|"
    echo "TASKS ${results[*]}"
  )
fi
