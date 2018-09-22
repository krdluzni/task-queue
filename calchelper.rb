def sort_value_by_rule(rule, task)
  eval($data["sort_rules"][rule]||0)
end

def sort_value(task)
  sort_value_by_rule($sort_rule, task)
end

def sort_operation(taskA, taskB)
  vA = sort_value(taskA)
  vB = sort_value(taskB)
  if vA == vB
    if taskA["id"] > taskB["id"]
      1
    else
      -1
    end
  elsif vA > vB
    -1
  else
    1
  end
end

