require 'json'

if ARGV.count < 2
  puts "params: <project> <field> [--force]"
end

$projectfile = ARGV[0]
field = ARGV[1]
force = false
force = (ARGV[2] == "--force") if ARGV.count >= 3

if File.exist?($projectfile+".json")
  file_in = File.read($projectfile+".json")
end
data = JSON.parse(file_in)

tasks = data["tasks"]
fields = data["known_fields"]
display = data["display_fields"]
creation = data["creation_fields"]

tasks = tasks.select do |this|
  this.include?(field)
end

tasks.each do |this|
  puts this[field].to_s
  case fields[field] 
  when "Integer"
    if this[field] == 0 || force
      this.delete(field)
    end
  when "Float"
    if this[field] == 0.0 || force
      this.delete(field)
    end
  when "Array"
    if this[field].empty? || force
      this.delete(field)
    end
  when "Time"
    if this[field] == 0 || force
      this.delete(field)
    end
  when "String"
    if this[field].empty? || force
      this.delete(field)
    end
  end
end

old_length = tasks.count

tasks = tasks.select do |this|
  this.include?(field)
end

new_length = tasks.count

puts "old: #{old_length}\nnew: #{new_length}\ncleaned: #{old_length-new_length}"

if new_length == 0
  fields.delete(field)
  display.delete(field)
  creation.delete(field)
end

File.open("#{$projectfile}.json", "w") do |file|
  file << JSON.pretty_generate(data)
end
