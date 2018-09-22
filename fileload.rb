def load_project()
  file_in = <<~HEREDOC
    {
      "tasks": [
      ],
      "known_fields": {
        "id": "Integer",
        "uuid": "UUID",
        "name": "Array"
      },
      "sort_rules": {
        "default": "0"
      },
      "foundations": {
        "default": []
      },
      "display_fields": [
        "name"
      ],
      "creation_fields": [
        "name"
      ],
      "inverse_keys": {},
      "display_calculations":[],
      "calculations":{},
      "render_count":10,
      "show_count": true
    }
  HEREDOC
  if File.exist?($projectfile+".json")
    file_in = File.read($projectfile+".json")
  end
  data = JSON.parse(file_in)

  $idgen = 1
  
  data["tasks"].each do |task|
    task["id"] = $idgen
    $idgen += 1
  end

  $foundation = (data["foundations"]["default"]||[])
  $sort_rule = (data["sort_rule_selected"]||"default")
  
  $page = 0
  
  return data
end