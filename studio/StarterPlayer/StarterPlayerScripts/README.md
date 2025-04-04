# StarterPlayerScripts

This folder contains scripts that define various functionalities for the Roblox game. Below is a detailed explanation of the key scripts in this folder:

## `Wave.luau`

The `Wave.luau` script is responsible for simulating realistic wave motion using mathematical models. It provides a framework for animating water surfaces in the game. Key features include:

1. **Wave Models**:
   - **Gerstner Waves**: The script uses the Gerstner wave model to simulate realistic wave motion. This model calculates wave displacement based on parameters such as wavelength, direction, steepness, and gravity.
   - **FFT Waves**: It also supports Fast Fourier Transform (FFT) waves, which add additional complexity and realism to the water surface.

2. **Zone-Based Modifiers**:
   - The script defines "calm zones" and "hard zones" in the water. These zones modify wave properties such as amplitude, wavelength, and vertical offset to create areas with different wave intensities.

3. **Bone-Based Animation**:
   - The script animates water surfaces by manipulating the positions of "bones" (special objects in Roblox) attached to the water planes. Each bone's position is updated based on the combined effects of multiple wave models.

4. **Performance Optimization**:
   - The script includes a distance-based optimization system. It only updates wave animations for water planes near the player, reducing the computational load.

5. **Customization**:
   - The script allows for extensive customization of wave properties through settings such as the number of waves, gravity, time modifiers, and maximum distance for updates.

6. **Real-Time Updates**:
   - The script uses `RunService.RenderStepped` to update wave animations in real-time, ensuring smooth and continuous motion.

## `WaveScript.luau`

The `WaveScript.luau` script acts as a controller for the `Wave.luau` module. It initializes and manages wave animations for multiple water planes in the game. Key features include:

1. **Initialization**:
   - The script retrieves all water planes in the game and creates a `Wave` instance for each plane using the `Wave.luau` module.

2. **Default Settings**:
   - It defines default wave settings, including the number of waves, FFT parameters, Gerstner wave properties, and maximum update distance.

3. **Real-Time Animation**:
   - The script connects each `Wave` instance to `RenderStepped`, ensuring that wave animations are updated in real-time.

4. **Scalability**:
   - The script is designed to handle multiple water planes efficiently, making it suitable for large-scale water environments.

## `ChunkGeneration.luau`

The `ChunkGeneration.luau` script handles the dynamic positioning of water planes to create an infinite ocean effect. Key features include:

1. **Dynamic Chunk Positioning**:
   - The script divides the ocean into a grid of chunks (water planes) and dynamically repositions these chunks based on the player's position. This creates the illusion of an infinite ocean.

2. **Grid-Based System**:
   - The script organizes water planes into a 5x5 grid around the player. Each plane's position is recalculated based on the player's current position and the chunk size.

3. **Real-Time Updates**:
   - The script continuously updates the positions of water planes in a loop, ensuring that the ocean always surrounds the player.

4. **Performance Optimization**:
   - By reusing a fixed number of water planes and repositioning them as needed, the script minimizes resource usage while maintaining the appearance of an expansive ocean.

5. **Seamless Transition**:
   - The script ensures that water planes are repositioned seamlessly, avoiding any noticeable gaps or jumps in the ocean surface.

These scripts work together to create a dynamic and immersive ocean environment in the game, combining realistic wave animations with efficient chunk-based rendering.