# Memory Leak Fixes

## Problem
Your neural network was continuously increasing RAM usage due to several memory leaks:

1. **Timer Objects Never Cleaned Up**: Each time a connection fired, it created a new Timer object that was never freed
2. **Duplicate Signal Connections**: Each time `recieve()` was called, it created new signal connections without cleaning up old ones
3. **Unlimited Connection Growth**: The network kept creating more and more connections without any limit

## Solutions Applied

### 1. **Fixed Connection Timer Leak**
**Before:**
```gdscript
# Created new timer every time connection fired
var timer : Timer = Timer.new()
self.add_child(timer)
timer.timeout.connect(func(): ...)
```

**After:**
```gdscript
# Reuse single timer per connection
var visual_timer : Timer  # Created once in _init
visual_timer.timeout.connect(_reset_color)  # Connected once
visual_timer.start(1.0)  # Just restart existing timer
```

### 2. **Fixed Neuron Signal Connection Leak**
**Before:**
```gdscript
# Created new signal connection every time neuron fired
timer.timeout.connect(func(): 
    self.state = false
    # ... reset code
)
```

**After:**
```gdscript
# Single timer connection made in _ready()
timer.timeout.connect(_reset_neuron_state)
timer_connected = true

func _reset_neuron_state():
    self.state = false
    # ... reset code
```

### 3. **Added Connection Limit**
**Before:**
```gdscript
# Unlimited connection creation
var new_conn = Connection.new(...)
connections.append(new_conn)
```

**After:**
```gdscript
# Limited to 50 connections maximum
if connections.size() < max_connections:
    var new_conn = Connection.new(...)
    connections.append(new_conn)
```

## Technical Details

### **Memory Leak Sources Fixed:**
- ❌ **Timer Object Leak**: ~1 Timer per connection fire (could be hundreds per second)
- ❌ **Signal Connection Leak**: ~1 signal connection per neuron activation
- ❌ **Unlimited Growth**: Connections growing infinitely over time

### **Memory Usage Now:**
- ✅ **Fixed Timer Count**: 1 timer per Connection + 1 timer per Neuron (total ~15 timers)
- ✅ **Fixed Signal Count**: 1 signal connection per timer (stable)
- ✅ **Limited Connections**: Maximum 50 connections total
- ✅ **Bounded Memory**: Memory usage will stabilize after initial network formation

### **Performance Impact:**
- **Startup**: Slightly longer (creating reusable objects)
- **Runtime**: Much better (no constant object creation/destruction)
- **Memory**: Stable after ~30 seconds instead of growing forever

## Monitoring

To verify the fixes are working:

1. **Task Manager**: RAM usage should stabilize after initial learning phase
2. **Godot Profiler**: Object count should remain stable
3. **Network Debug**: Connection count should cap at 50

## Configuration

You can adjust these limits in `neuronal_network.gd`:

```gdscript
var max_connections : int = 50  # Increase if you need more connections
var base_learning_rate : float = 0.05  # Adjust learning speed
```

## Expected Behavior

- **First 30 seconds**: RAM may increase as network builds connections
- **After 30 seconds**: RAM usage should stabilize and remain constant
- **Connection creation**: Should stop printing new connections after reaching limit
- **Learning**: Should continue even with fixed number of connections

Your neural network should now run indefinitely without memory issues!
