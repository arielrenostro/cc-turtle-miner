# Computer Craft - Turtle Miner

## Description
Automatic mining turtle distribuited system. It uses a controller in a orchestrator mode to create and manage the mining task, dividing this big task in small ones and ordering the turtles to dig it.

### Controller
An Advanced Computer with 6x3 touch monitors for control and monitor the mining progress. It orchestrate the mining task amoung all available turtles.

### Operator
An Advanced Turtle with a Pickaxe that executes the mining tasks from the Controller. It uses a GPS for location, store items into a storage chest and refuel from another chest.

### TODO:
- Comunicate with an orchestrator;
- Implements the orchestration
- Implements the comunication protocol;
- Implements the task spliter;


## Release notes
### v0.0.3
- Starting Controller tests;
- Codes from Operator and Controller splited;
- New render monitor API for screen projections;
- Examples and tests added to project.

[![ComputerCraft - Mining Turtle V0.0.3](https://img.youtube.com/vi/6GVynJb20yM/0.jpg)](http://www.youtube.com/watch?v=6GVynJb20yM "ComputerCraft - Mining Turtle V0.0.3")

### v0.0.2
- State are now stored in a file;
- State module created;
- Navigator module created;
- Files refactor;
- Project organization;
- And Minor improvements.


### v0.0.1
- First version

[![ComputerCraft - Mining Turtle V0.0.1](https://img.youtube.com/vi/EFWonYmRnjo/0.jpg)](http://www.youtube.com/watch?v=EFWonYmRnjo "ComputerCraft - Mining Turtle V0.0.1")