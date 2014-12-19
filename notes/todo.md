#Todo for loon

##Pegylator

###0.0.1

- write PEG format parser (done)

- Modify epng into epeg:

	- metatables for nodes

	- proper index, back references

	- add code regions (start, end : <Position>)

	- Add line-column reporting (regioned => <Position> := start: <LinePosition, end: <LinePosition> )

###0.0.2

- Rule elimination

- Left-right balancing 

- Match conversion

###0.0.3

- Code generation (main engine)

	- write unit tests for each type of rule conversion

	- write transforms for each type of rule conversion

	- profit
