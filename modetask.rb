def task_mode

  task = $selected_task.last
  $data["display_fields"].each do |field|
    if $data["known_fields"].include?(field)
      case $data["known_fields"][field]
      when "UUID_Array"
        puts "#{field}:"
        (task[field]||[]).each do |uuid|
          refersto = $data["tasks"].find do |task| task["uuid"] == uuid end
          puts "\t#{(refersto["name"]).to_s}"
        end
      else
        puts "#{field}: #{task[field].to_s}"
      end
    end
  end
  puts ""

  if $render_extra_fields
    ($data["known_fields"].keys-$data["display_fields"]).each do |field|
      case $data["known_fields"][field]
      when "UUID_Array"
        puts "#{field}:"
        (task[field]||[]).each do |uuid|
          refersto = $data["tasks"].find do |task| task["uuid"] == uuid end
          puts "\t#{(refersto["name"]).to_s}"
        end
      else
        puts "#{field}: #{task[field].to_s}"
      end
    end
    puts ""
    
    $data["sort_rules"].each do |key,val|
      puts "sort(#{key}): #{eval(val)}"
    end
    puts ""

    $render_extra_fields = false
  end
  
  puts "(f)ield | (r)eturn | delete(\\) | show hidden(p) | (c)apture | return to (l)ist"
  command = gets.chomp.strip
  case command
  when "r"
    $selected_task.pop()
  when "f"
    puts "field?"
    field = gets.chomp.strip
    if !$data["known_fields"].include?(field)
      puts "unknown field: #{field}"
      puts "(s)tring | (a)rray | (i)nteger | (f)loat | (t)ime | uuid array(ua)"
      type = gets.chomp.strip
      case type
      when "s"
        $data["known_fields"][field] = String.to_s
      when "a"
        $data["known_fields"][field] = Array.to_s
      when "i"
        $data["known_fields"][field] = Integer.to_s
      when "f"
        $data["known_fields"][field] = Float.to_s
      when "t"
        $data["known_fields"][field] = Time.to_s
      when "ua"
        $data["known_fields"][field] = "UUID_Array"
        loop do
          puts "inverse?"
          inverseKey = gets.chomp.strip
          if inverseKey != ""
            $data["known_fields"][inverseKey] = "UUID_Array"
            $data["inverse_keys"][field] = inverseKey
            $data["inverse_keys"][inverseKey] = field
            break
          end
        end
      else
        return
      end
    end
  
    case $data["known_fields"][field]
    when String.to_s
      puts "#{field}(#{task[field].to_s})?"
      task[field] = gets.chomp.strip
    when Integer.to_s
      puts "#{field}(#{task[field].to_s})?"
      task[field] = gets.chomp.strip.to_i
    when Float.to_s
      puts "#{field}(#{task[field].to_s})?"
      task[field] = gets.chomp.strip.to_f
    when Time.to_s
      puts "#{field}(#{task[field].to_s})?"
      task[field] = (Time.now + gets.chomp.strip.to_f*24*60*60).to_i
    when Array.to_s
      puts "#{field}?"
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
    when "UUID_Array"
      puts "#{field}?"
      task[field] ||= []
      loop do
        task[field].each_with_index do |uuid, index|
          refersto = $data["tasks"].find do |task| task["uuid"] == uuid end
          puts "#{index.to_s}: #{(refersto["name"]).to_s}"
        end
        puts "(a)dd | (r)emove | (d)elete index | (f)ollow"
        case gets.chomp.strip
        when "a"
          refersto = $data["tasks"].find do |task| task["uuid"] == $captured_uuid end
          if refersto == nil
            puts "Dead UUID! Aborting add..."
            $captured_uuid = nil
          else
            puts "add #{refersto["name"].to_s}?"
            confirmation = gets.chomp.strip
            if confirmation == "y" || confirmation == "yes"            
              task[field] << $captured_uuid
              
              inverseKey = $data["inverse_keys"][field]
              refersto[inverseKey] ||= []
              refersto[inverseKey] << task["uuid"]
            end
          end
        when "r"
          refersto = $data["tasks"].find do |task| task["uuid"] == $captured_uuid end
          if refersto == nil
            puts "Dead UUID! Aborting remove..."
            $captured_uuid = nil
          else
            puts "remove #{refersto["name"].to_s}?"
            confirmation = gets.chomp.strip
            if confirmation == "y" || confirmation == "yes"
              task[field].delete($captured_uuid)
              
              refersto = $data["tasks"].find do |task| task["uuid"] == $captured_uuid end
              inverseKey = $data["inverse_keys"][field]
              refersto[inverseKey] ||= []
              refersto[inverseKey].delete(task["uuid"])
            end
          end
        when "d"
          puts "delete index?"
          deleted = task[field].delete_at(gets.chomp.strip.to_i)
          
          refersto = $data["tasks"].find do |task| task["uuid"] == deleted end
          inverseKey = $data["inverse_keys"][field]
          refersto[inverseKey] ||= []
          refersto[inverseKey].delete(task["uuid"])
        when "f"
          puts "follow?"
          index = gets.chomp.strip.to_i
          if task[field].count > index
            follow_id = task[field][index]
            refersto = $data["tasks"].find do |task| task["uuid"] == follow_id end
            $selected_task << refersto if refersto != nil
            break
          end
        else
          break
        end
      end
    end
  when "\\"
    puts "are you sure?"
    return if gets.chomp.strip != "yes"
    
    uuid_array_fields = $data["known_fields"].select do |key,val| val == "UUID_Array" end
    uuid_array_fields.each do |key,val|
      (task[key]||[]).each do |ref_id|
        refersto = $data["tasks"].find do |task| task["uuid"] == ref_id end
        inverseKey = $data["inverse_keys"][key]
        refersto[inverseKey].delete(task["uuid"])
      end
    end
    
    $data["tasks"].delete(task)
    $selected_task.pop()
  when "p"
    $render_extra_fields = true
  when "c"
    $captured_uuid = $selected_task.last["uuid"]
  when "l"
    $selected_task = []
  end
end