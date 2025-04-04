# Python Script for Creating Bones on a Plane in Blender

This Python script automatically generates bones on a plane in Blender. The bones are created based on the positions of the plane's vertices, sorted by their coordinates.

## Prerequisites

- **Blender**: Make sure Blender is installed on your machine.
- **Plane named "Plane"**: The script works with an object named `Plane` in your Blender scene.

## Usage Instructions

1. **Add a plane to your Blender scene**:
   - Go to the menu `Add > Mesh > Plane` to add a plane.
   - Rename the object to `Plane` if it is not already named that.

2. **Load the script in Blender**:
   - Open Blender.
   - Switch to the `Scripting` editor.
   - Create a new file or open an existing one.
   - Copy and paste the Python script into the text editor.

3. **Run the script**:
   - Click the `Run Script` button in the text editor.
   - The script will automatically:
     - Switch to edit mode to retrieve the plane's vertices.
     - Create an armature with bones aligned to the plane's vertices.
     - Display information about the created bones in Blender's console.

4. **Check the results**:
   - An armature will be added to your scene.
   - The bones will be positioned based on the plane's vertices.

## How the Script Works

The script performs the following steps:
1. Retrieves the plane's vertices in edit mode.
2. Sorts the vertices by their `(y, x)` coordinates to ensure consistent ordering.
3. Creates an armature and adds a bone for each vertex:
   - The bone's head is positioned at the vertex.
   - The bone's tail is slightly offset in the `z` direction to give the bone length.

## Example Output in the Console

When executed, the script displays information about the created bones in Blender's console. Example:
```bash
Bone: Bone_001, Head: <Vector (1.0000, 1.0000, 0.0000)>, Tail: <Vector (1.0000, 1.0000, 0.1000)> Bone: Bone_002, Head: <Vector (0.0000, 1.0000, 0.0000)>, Tail: <Vector (0.0000, 1.0000, 0.1000)> ...
```
