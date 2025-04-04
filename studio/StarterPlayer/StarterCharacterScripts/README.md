# StarterCharacterScripts

This folder contains scripts that define custom behaviors for the player's character in the Roblox game. Below is an explanation of the two main scripts in this folder:

## `Pitching.luau`

The `Pitching.luau` script is responsible for dynamically adjusting the orientation and position of floating objects in the game to simulate realistic water physics. It achieves this by:

1. **Bone Cache System**: The script uses a caching system to store the positions of bones in the water planes. These bones are used to calculate the water surface's dynamic height at any given point.
2. **Dynamic Water Level Calculation**: The script calculates the water level at specific points by interpolating the positions of nearby bones.
3. **Object Orientation Adjustment**: The script adjusts the orientation of floating objects based on the water surface's tilt and height. It uses spring-based interpolation to smooth out the movements and rotations of the objects.
4. **Real-Time Updates**: The script continuously updates the positions and orientations of objects in real-time using Roblox's `RunService.Heartbeat`.

This script ensures that objects floating on the water behave naturally, responding to waves and tilts in the water surface.

## `Swimming.luau`

The `Swimming.luau` script handles the player's swimming mechanics and underwater effects. It includes the following features:

1. **Dynamic Water Level Detection**: Similar to `Pitching.luau`, this script calculates the water level dynamically using the positions of bones in the water planes.
2. **Swimming Animation**: The script plays a swimming animation when the player is underwater and stops it when the player exits the water.
3. **Underwater Effects**: When the player is underwater, the script enables visual effects such as blur and color correction to simulate an underwater environment. These effects are disabled when the player surfaces.
4. **Buoyancy and Movement**: The script adjusts the player's vertical velocity to simulate buoyancy. It also allows the player to move upward by pressing the spacebar.
5. **State Management**: The script manages the player's humanoid states to ensure smooth transitions between swimming and other actions.

This script provides an immersive swimming experience for the player, complete with realistic visuals and physics-based movement.