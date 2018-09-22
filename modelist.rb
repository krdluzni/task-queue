def list_mode
  $current_view = $data["tasks"].select do |task|
    ($foundation|$filters).select do |rule|
      check = !rule["negate"]
      case rule["comparison"]
      when "is", "="
        case $data["known_fields"][rule["field"]]
        when Array.to_s, "UUID_Array"
          check = (task[rule["field"]]||[]).any? do |entry| entry == rule["target"] end
        else
          check = task[rule["field"]] == rule["target"]
        end
      when "has"
        case $data["known_fields"][rule["field"]]
        when Array.to_s, "UUID_Array"
          check = (task[rule["field"]]||[]).any? do |entry| entry.include?(rule["target"]) end
        else
          check = (task[rule["field"]]||[]).include?(rule["target"])
        end
      when "greater than", ">"
        case $data["known_fields"][rule["field"]]
        when Time.to_s
          check = (task[rule["field"]]||0) > (Time.now + rule["target"]*24*60*60).to_i
        else
          check = (task[rule["field"]]||0) > rule["target"]
        end
      when "less than", "<"
        case $data["known_fields"][rule["field"]]
        when Time.to_s
          check = (task[rule["field"]]||0) < (Time.now + rule["target"]*24*60*60).to_i
        else
          check = (task[rule["field"]]||0) < rule["target"]
        end
      when "missing"
        case $data["known_fields"][rule["field"]]
        when Array.to_s, String.to_s, "UUID", "UUID_Array"
          check = (task[rule["field"]] == nil || task[rule["field"]].empty?)
        else
          check = (task[rule["field"]] == nil)
        end
      else
        check = !rule["negate"]
      end
      check == rule["negate"]
    end.count == 0
  end

  $current_view.sort! do |taskA, taskB|
    sort_operation(taskA, taskB)
  end
  
  while $page > 0 && $page * $data["render_count"] >= $current_view.count do
    $page = $page - 1
  end
  
  $data["render_count"].times do |iter|
    iter = iter + $page * $data["render_count"]
    if $current_view.count > iter
      task = $current_view[iter]
      puts "id: #{task["id"]}"
      $data["display_fields"].each do |field|
        if $data["known_fields"].include?(field)
          puts "#{field}: #{task[field].to_s}"
        else
          puts "#{field}: #{sort_value_by_rule(field, task)}"
        end
      end
      puts ""
    end
  end

  if $data["show_count"]
    puts "count: #{$current_view.count}"
  end
  
  puts "page: #{$page+1}"
  puts ""
  
  $data["display_calculations"].each do |calc_name|
    if $data["calculations"].include?(calc_name)
      calc = $data["calculations"][calc_name]
      
      total = $current_view.inject(0) do |acc, task|
        acc + eval(calc)
      end
      
      average = 0
      if $current_view.count > 0
        average = total/$current_view.count
      end
      
      puts "average #{calc_name}: #{average}"
      puts "total #{calc_name}: #{total}"
      puts ""
    end
  end

  puts "e(x)it | (w)rite | (a)dd | (f)ilter | (r)eset | (s)elect | (u)uid select | rand(o)m | export(>) | delete(\\) | foundation(?) | next page(]) | previous page([) | (m)eta | switch pro(j)ects"
  command = gets.chomp.strip
  case command
  when "x"
    exit
  when "w"
    $data["tasks"].sort! do |taskA, taskB|
      sort_operation(taskA,taskB)
    end
  
    File.open("#{$projectfile}.json", "w") do |file|
      file << JSON.pretty_generate($data)
    end
  when ">"
    puts "filename?"
    filename = gets.chomp.strip
    File.open("#{filename}.export.json", "w") do |file|
      exportdata = $data.dup
      exportdata["tasks"] = $current_view
      file << JSON.pretty_generate(exportdata)
    end
  when "a"
    task = {}
    task["id"] = $idgen
    $idgen += 1
    task["uuid"] = SecureRandom.uuid
    $data["creation_fields"].each do |field|
      puts "#{field}?"
      case $data["known_fields"][field]
      when String.to_s
        task[field] = gets.chomp.strip
      when Integer.to_s
        task[field] = gets.chomp.strip.to_i
      when Float.to_s
        task[field] = gets.chomp.strip.to_f
      when Time.to_s
        task[field] = (Time.now + gets.chomp.strip.to_i*24*60*60).to_i
      when "UUID"
        puts "paste #{$captured_uuid}?"
        confirmation = gets.chomp.strip
        if confirmation == "y" || confirmation == "yes"
          task["field"] = $captured_uuid
        end
      when "UUID_Array"
        task[field] ||= []
        loop do
          task[field].each_with_index do |val, index|
            puts "#{index.to_s}: #{val.to_s}"
          end
          puts "(a)dd | (r)emove | (d)elete index"
          case gets.chomp.strip
          when "a"
            puts "add #{$captured_uuid}?"
            confirmation = gets.chomp.strip
            if confirmation == "y" || confirmation == "yes"
              task[field] << $captured_uuid
            end
          when "r"
            puts "remove?"
            task[field].delete(gets.chomp.strip)
          when "d"
            puts "delete index?"
            task[field].delete_at(gets.chomp.strip.to_i)
          else
            break
          end
        end
      when Array.to_s
        task[field] ||= []
        loop do
          task[field].each_with_index do |val, index|
            puts "#{index.to_s}: #{val.to_s}"
          end
          puts "(a)dd | (r)emove | (d)elete index"
          case gets.chomp.strip
          when "a"
            puts "add?"
            task[field] << gets.chomp.strip
          when "r"
            puts "remove?"
            task[field].delete(gets.chomp.strip)
          when "d"
            puts "delete index?"
            task[field].delete_at(gets.chomp.strip.to_i)
          else
            break
          end
        end
      end  
    end
    $data["tasks"] << task
    $selected_task.push(task)
  when "f"
    puts "field?"
    field = gets.chomp.strip
    return if !$data["known_fields"].keys.include?(field)
    puts "comparison?"
    comparison = gets.chomp.strip
    puts "target?"
    case $data["known_fields"][field]
    when Integer.to_s
      target = gets.chomp.strip
      target = target.to_i
    when Float.to_s
      target = gets.chomp.strip
      target = target.to_f
    when Time.to_s
      target = gets.chomp.strip
      target = target.to_i
    when "UUID", "UUID_Array"
      puts "paste #{$captured_uuid}?"
      confirmation = gets.chomp.strip
      if confirmation == "y" || confirmation == "yes"
        target = $captured_uuid
      else
        return
      end
    else
      target = gets.chomp.strip
    end
    puts "negate?"
    negate = gets.chomp.strip == "y"
    newFilter = {}
    newFilter["field"] = field
    newFilter["comparison"] = comparison
    newFilter["target"] = target
    newFilter["negate"] = negate
    $filters << newFilter
    
    $page = 0
  when "r"
    $filters = []
    $page = 0
  when "s"
    puts "id?"
    id = gets.chomp.strip.to_i
    t = $data["tasks"].find do |task| task["id"] == id end
    $selected_task.push(t) if t != nil
  when "u"
    id = $captured_uuid
    t = $data["tasks"].find do |task| task["uuid"] == id end
    $selected_task.push(t) if t != nil
  when "o"
    if $current_view.count > 0
      random_index = Random.rand($current_view.count)
      $selected_task.push($current_view[random_index])
    end
  when "\\"
    puts "are you sure?"
    return if gets.chomp.strip != "yes"
    puts "are you REALLY sure?"
    return if gets.chomp.strip != "REALLY"
    
    $current_view.each do |task|
      uuid_array_fields = $data["known_fields"].select do |key,val| val == "UUID_Array" end
      uuid_array_fields.each do |key,val|
        (task[key]||[]).each do |ref_id|
          refersto = $data["tasks"].find do |task| task["uuid"] == ref_id end
          inverseKey = $data["inverse_keys"][key]
          refersto[inverseKey].delete(task["uuid"])
        end
      end
    end
    
    $data["tasks"].delete_if do |task| $current_view.include?(task) end
  when "?"
      puts "foundation?"
      puts $data["foundations"].keys.join(" | ")
      $foundation = ($data["foundations"][gets.chomp.strip]||[])
      $page = 0
  when "m"
    $meta_mode = true
  when "j"
    puts "project?"
    $projectfile = gets.chomp.strip
    $data = load_project()
  when "["
    if $page > 0
      $page = $page - 1
    end
  when "]"
    $page = $page + 1
  end
end