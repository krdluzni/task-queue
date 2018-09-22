# What is this?

Most task management tools I've seen expect you to manually sort the tasks, or assign priority values to them. This tool was created to test a different approach, where you feed the tool more data about the task, and it assigns priorities for you based on a customizable heuristic.

I am personally pleased with the results, but your mileage may vary. Additionally, as this tool was originally written as an experiment, I can make no guarantees regarding stability or safety of using this tool.

# How do I launch the tool?

You will need to have a ruby language interpreter installed. This tool was created and tested with `ruby 2.4.1p111 (2017-03-22 revision 58053) [x64-mingw32]`. I have currently switched to `ruby 2.5.1p57 (2018-03-29 revision 63029) [x64-mingw32]` and have seen no issues with it, yet.

Without file associations: `ruby -- task-queue.rb`.

If you have file associations set up for ruby scripts, you can launch it with just: `task-queue.rb`.

# How does this work? (An example):

In my case, I give the tool the following data for each task:
A numeric score for how much value it will create.
How many hours I expect it to take.
How much money it will cost (in dollars).
A list of things about the task that make it more complicated, or frustrating, or bothersome.
A list of other tasks that can't be started until this one is done.
A list of reasons to do the task that aren't about creating value.
A date until which the task is not to be considered.

The tool then calculates a score for each task according to the following formula (roughly):
`(value * 6 + reasons.count * 6 + task.dependencies * 4)/(complexities.count * 5 + hours * 1 + cost * 0.1 + 0.0001)`

And sorts them according to that information.

It also uses some filtering rules to hide anything that should not be considered yet, or that is blocked by other tasks. After that, it displays the top few items from this list. 

# Why is this a good thing?

When new tasks are added, just fill in the same data, and they get slotted into the correct place dynamically. And when things change, and a new complexity or reason is discovered, I can just add that, and again, it will dynamically find its new place.

Even the heuristic can be changed. Want to spend less money? Change the formula to use cost * 10, and anything that costs money will shuffle automatically to a lower spot on the list. Having a rough day, and want to do something simple? Change the multiplication factor on complexities.count.

# Are there any downsides?

Unlike a lot of task management tools out there, this is a tool for a single user. This is because it's just a command line tool with local data, and not a web-based tool. Additionally, getting multiple users to agree on a good heuristic is not something I expect to be easy.

It's also a command-line tool. No fancy interface, just typing into a console and reading text.

Lastly, while the heuristic isn't hard to configure, it is written in code (ruby). This allows a lot of flexibility, but may seem overly complicated to non programmers. The formula mentioned in the example actually looks like this:

`((task["value"]||0) * 6 + (task["reason"]||[]).count * 6 + dependency_score(task) * 4)/((task["complexity"]||[]).count * 5 + (task["hours"]||0) * 1 + (task["cost"]||0) * 0.1 + 0.0001)`

# How do I actually use this?

When you launch this tool, it will look for a file called default.json in your current directory. If it doesn't find it, it will create a blank project with that name. If it does, it will load the project contained within.

An empty project will display information like the following:

```
count: 0
page: 1

e(x)it | (w)rite | (a)dd | (f)ilter | (r)eset | (s)elect | (u)uid select | rand(o)m | export(>) | delete(\) | foundation(?) | (m)eta | switch pro(j)ects
```

This is the list view that shows you all tasks in your current project.

The prompts along the bottom exist to tell you what your available commands are. To execute a command, type the character inside parentheses, and press enter. It will then prompt you for further information if needed to execute the command.
## List view commands
### e(x)it
Closes the program.
### (w)rite
Saves the project.
### (a)dd
Creates a new task.
### (f)ilter
Runs a search for tasks meeting rules you define.
### (r)eset
Removes all current filters from the view.
### (s)elect
Selects a single task (by id) and switches to Task view.
### (u)uid select
Selects a single task (by UID) and switches to Task view.
### rand(o)m
Selects a random task from the current view and switches to Task view.
### export(>)
Creates a new project containing only tasks in the currently filtered list.
### delete(\)
Deletes all tasks in the current list. You will be asked to confirm TWICE since it is not possibly to undo. For the first confirmation type 'yes', for the second type 'REALLY'.
### foundation(?)
Foundations are preconfigured filter collections. This allows you to switch between them, or (by not selecting any) turn the foundation off. Foundations are NOT cleared when using the reset command.
### (m)eta
This loads the Meta view, where you change things about the project or the display rather than about individual tasks.
### switch pro(j)ects
Switches to a different project, or if the selected project does not exist, starts a new empty one with the chosen name.

## Task view commands
### (f)ield
Modify the value in a field. If the field name is not recognized, this will create a new field definition for the project. For uuid array fields, this will also allow you to switch to a related task stored in that field.
### (r)eturn
Go back to the previous view.
### delete(\)
Delete this task. It will prompt for confirmation (type 'yes').
### show hidden(p)
Show ALL fields for this task, including those not shown by default. The list of default visible fields can be configured from the Meta view. This will also allow you to see the score generated for this task by all known sort rules.
### (c)apture
Store the current task's uuid, for use with other commands.
### return to (l)ist
If you followed a chain of uuid array elements to end up at the current task (r)eturn will only send you back to the previous task. This command will instead return you directly to the List view.

## Meta view commands
### (r)eturn
Return to the List view.
### (d)isplay fields
Configure which fields are displayed by default (in both the List view and the Task view). You can also use the name of a sort rule to make that a default-displayed value.
### (s)ort rules
Define sort rules/heuristics. You'll need to enter a ruby expression that will yield a single value. Larger results are considered higher priority tasks.
### (c)reation fields
Edit the list of fields for which you will automatically be prompted when creating a new task.
### (f)oundations
Define or delete foundations from the project. (c)apture here will take your current foundation + filters and turn them into a new foundation with your chosen name.
### (q)uantity
Configure how many tasks are shown per page in list view.
### show co(u)nt
Configure whether to display the total count of tasks in the current list.
### change sor(t)
Switch to a different sort rule/heuristic.
### ca(l)c fields
The list view can calculate averages and totals for values based on the whole list (eg. total hours to complete the current list view, and average hours per task in the current list view). This is where you define the values for which these calculations should be done. As is the case for sort rules, these calculations are ruby expressions.
### displa(y) calcs
Configure which calculations should be displayed in the list view.

# Advanced topics
## Optimal usage recommendations
### Keeping backups
Creating a backup is as simple as running the export(>) command on the entire project. Alternatively, you can store the file somewhere that is saved to the cloud with Dropbox, or some other tool that automatically keeps file history.
### Cleaning up old fields
Occasionally, you may find that some fields you have created are no longer useful to you. Inside this repository is a script called clean-unused-fields.rb. If you call that field with a project name and a field name, it will attempt to remove that field from the project. Note: It will only actually remove it if the field is empty in ALL tasks.  For numeric fields this means undefined or set to 0. For arrays, it means an empty array. For strings it means an empty string. If this condition is not met, it will list out all values it encountered that were not possible to clear.
## Time values
When entering time values (for data entry, or for filters), they are a numeric value indicating the number of days between the current time and the chosen time.  Eg. 2.5 -> 2 and a half days from now.  -10 -> 10 days ago. However, when the values are displayed, they are shown as epoch time of the resulting date.
## Project file format
Project files are simple json files. If necessary, they can be edited by hand as long as the structure of the json data is preserved.
## Ruby expressions
When entering ruby expressions for calc fields or sort rules, you have access to a variable called task that contains the task information as a dictionary. You also, technically have access to all global variables of the program. It is strongly recommended that you not use the global variables at all, and only use the task to read data without modifying it.
## Plugins
If the tool is called with an additional parameter on the command-line, that parameter will be assumed to be the absolute path to an additional ruby file that should be loaded at runtime. Any functions you define in that file will be accessible from ruby expressions, in case you would like to perform more complicated calculations. Eg. I use a function defined via plugin in one of my own projects to recursively walk the dependency graph for a task and assign a dependency_score based on how many tasks are blocked by the current one.
If using a plugin script, I recommend using a batch file to launch the tool so that you can type significantly less.
