require 'json'
require 'securerandom'

require_relative 'fileload'
require_relative 'calchelper'
require_relative 'modemeta'
require_relative 'modelist'
require_relative 'modetask'
require_relative ARGV[0] if ARGV.length > 0

$projectfile = "default"
$foundation = []
$selected_task = []
$current_view = []
$filters = []
$idgen = 1
$meta_mode = false
$page = 0
$render_extra_fields = false
$sort_rule = "default"
$captured_uuid = nil

$data = load_project()

ARGV.clear()

loop do
  system "cls"
  
  if $meta_mode
    meta_mode()
  elsif $selected_task.empty?
    list_mode()
  else
    task_mode()
  end
end
