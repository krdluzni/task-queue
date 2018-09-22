def meta_mode
  puts "status"
  puts "quantity: #{$data["render_count"]}"
  puts "showing count: #{$data["show_count"]}"
  puts "sort rule: #{$sort_rule} => #{$data["sort_rules"][$sort_rule]||0}"
  puts ""
  puts "(r)eturn | (d)isplay fields | (s)ort rules | (c)reation fields | (f)oundations | (q)uantity | show co(u)nt | change sor(t) | ca(l)c fields | displa(y) calcs"
  
  case gets.chomp.strip
  when "r"
    $meta_mode = false
  when "l"
    loop do
      puts "calculations:"
      $data["calculations"].each do |name, rule|
        puts "#{name}: #{rule}"
      end
      puts "(a)dd | (r)emove"
      case gets.chomp.strip
      when "a"
        puts "name?"
        name = gets.chomp.strip
        puts "calc?"
        $data["calculations"][name] = gets.chomp.strip
      when "r"
        puts "remove?"
        $data["calculations"].delete(gets.chomp.strip)
      else
        break
      end
    end
  when "y"
    loop do
      puts "display calculations:"
      puts "#{$data["display_calculations"]}"
      puts "(a)dd | (r)emove"
      case gets.chomp.strip
      when "a"
        puts "field?"
        field = gets.chomp.strip
        if $data["calculations"].include?(field)
          $data["display_calculations"] << field
        end
      when "r"
        puts "remove?"
        $data["display_calculations"].delete(gets.chomp.strip)
      else
        break
      end
    end
  when "d"
    loop do
      puts "display fields:"
      puts "#{$data["display_fields"]}"
      puts "(a)dd | (r)emove"
      case gets.chomp.strip
      when "a"
        puts "field?"
        field = gets.chomp.strip
        if $data["known_fields"].include?(field) || $data["sort_rules"].include?(field)
          $data["display_fields"] << field
        end
      when "r"
        puts "remove?"
        $data["display_fields"].delete(gets.chomp.strip)
      else
        break
      end
    end
  when "s"
    loop do
      puts "sort rules:"
      $data["sort_rules"].each do |name, rule|
        puts "#{name}: #{rule}"
      end
      puts "(a)dd | (r)emove"
      case gets.chomp.strip
      when "a"
        puts "name?"
        name = gets.chomp.strip
        puts "rule?"
        $data["sort_rules"][name] = gets.chomp.strip
      when "r"
        puts "remove?"
        $data["sort_rules"].delete(gets.chomp.strip)
      else
        break
      end
    end
  when "c"
    loop do
      puts "creation_fields:"
      puts "#{$data["creation_fields"]}"
      puts "(a)dd | (r)emove"
      case gets.chomp.strip
      when "a"
        puts "field?"
        field = gets.chomp.strip
        if $data["known_fields"].include?(field)
          $data["creation_fields"] << field
        end
      when "r"
        puts "remove?"
        $data["creation_fields"].delete(gets.chomp.strip)
      else
        break
      end
    end
  when "t"
    puts "sort rules:"
    $data["sort_rules"].each do |name, rule|
      puts "#{name}: #{rule}"
    end
    puts "name?"
    rule = gets.chomp.strip
    if $data["sort_rules"].include?(rule)
      $sort_rule = rule
      $data["sort_rule_selected"] = rule
    end
    $page = 0
  when "f"
    loop do
      puts "foundations:"
      $data["foundations"].each do |name, foundation|
        puts "#{name}: #{foundation}"
      end
      puts "(c)apture | (r)emove"
      case gets.chomp.strip
      when "c"
        puts "name?"
        $data["foundations"][gets.chomp.strip] = ($foundation|$filters)
      when "r"
        puts "remove?"
        $data["foundations"].delete(gets.chomp.strip)
      else
        break
      end
    end
  when "q"
    puts "quantity?"
    $data["render_count"] = gets.chomp.strip.to_i
  when "u"
    $data["show_count"] = !$data["show_count"]
  end
end