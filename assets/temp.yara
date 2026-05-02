```
goto begin
```

# Act 1 {#begin}

```
focus splash ; show the big splash screen. when an element is focused it becomes 'this' and text is applied to it
```

Act 1

```
add option ; adding a new node like an option also focuses it
```
Continue
```
set method on_click
goto gas_station
; additional code to be run on click can go here
```

## Gas Station {#gas_station}

```
clear scene
focus title
```

The gas station.

```
set speaker "???"
set text "Smile, scan, bag." ; this an alternate way of writing to an element, in this case the text box
await ; instead of needing to always create a continue node like above you can use this shortcut
; pauses execution util the player presses continue
; goes on to the first child node if any, otherwise next node in parent if any, otherwise ends
```
