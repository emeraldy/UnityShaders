# Unity HLSL Shaders
## Scene: basiclighting
<img src = "/screenshots/basiclighting.png" width = "385" height = "240"/>

This scene employs a directional light based on the phong shading model to shade the spaceship. The light direction is symbolised by the game object *Light\_dir*. There are 2 shaders in this scene (located under Assets\\Shaders\\basiclighting): **light\_dir** and **ship\_dir**.

### Light\_dir
A pass-through shader to give the game object *Light\_dir* some shading. Its properties, *Ambient*, *Diffuse* and *Specular*, can be changed to different colours in the game object’s inspector window.

### Ship\_dir
The shader is used by the spaceship’s material *ship_dir* and responsible for implementing the phong model. You can change its properties, *Ambient*, *Diffuse* and *Specular* and *Shininess* to alter the shading result of the ship. Note that properties starting with "Light" are populated by the script "LightControl dir.cs" and changing them manually here has no effect. Although I didn’t implement a control scheme for changing the light direction during the play time, the actual direction does get passed into the shader at each frame. Therefore, you can manually change the orientation of the game object *Light \_dir* in the scene window during play and observe the shading result changes accordingly.

## Scene: coordinates
This scene demonstrates some Unity shader basics through visualising coordinate components of various coordinate systems in the pipeline. There are 3 shaders in this scene (located under Assets\\Shaders\\coordinates): **colour\_ objz**, **colour\_viewx** and **colour\_screeny**.

### Colour\_objz
This shader visualises the z components of vertices in the object space. To see the effect of this shader, go to Assets\\Materials\\coordinates in the *project* window and drag it onto the spaceship model in the scene. Run the scene and as you can see, the coordinate value is encoded in red with less values darker and greater values brighter.

### Colour\_viewx
This shader visualises the x components of vertices in the camera space. After applying the corresponding shader to the spaceship, click *Spaceship* in the hierarchy window and enable the component "**Colour viewx (Script)**" in the inspector. Make sure the other script "**Colour screeny (Script)**" is disabled. Run the scene and as you can see, the pixels to the left are always darker (less x) than the ones to the right (greater x).

### Colour\_screeny
This shader visualises the y components of vertices in the screen space. After applying the corresponding shader to the spaceship, click Spaceship in the hierarchy window and enable the component "**Colour screeny (Script)**" in the inspector. Make sure the other script "**Colour viewx (Script)**" is disabled. Run the scene and click anywhere in the game window once to receive the initial correct rendering. As you can see, the pixels to the bottom are always darker (less y) than the ones to the top (greater y). Admittedly, this effect can be confused with the one in camera space but if you don’t run it in maximised game window and then try to resize the window in the y direction, you can be convinced that this is visualising the screen space coordinates.

## Scene: deferrendering
Defer rendering of the spaceship with phong lighting model is implemented in this scene. First, *GbufferCamera* renders the spaceship with **gbufferproducer** shader to generate the g-buffers. In this implementation, each g-buffer contains one of the 3 lighting components --- diffuse, specular and ambient (blended with colour information from the spaceship texture already). Subsequently, a second camera renders a full-screen quad with shader **gbufferassembler** to composite the final shading of the spaceship. Both shaders can be found under Assets\\Shaders\\derferrendering.

### Gbufferproducer
The main calculation is done in the fragment shader here. To generate the 3 g-buffers, the shader computes the diffuse, specular terms as well as sampling the spaceship texture for colour information and then writes them out to 3 render target textures (*\_GB\_ Diff*, *\_GB\_Spec* and *\_GB\_Colo*) passed in as material properties.

### Gbufferassembler
This shader reads in the 3 g-buffers and composites them for each fragment of the full-screen quad.

## Scene: depth
First of all, probably due to Unity ShaderLab internal implementation quirk of rendering to texture, this effect doesn't work with D3D but has no problem with OpenGL. Therefore, you need to add "-force-opengl" to command line argument when starting the whole project in order to run this scene as intended. I will investigate further when I have time.

This scene demonstrate the depth of field effect, which blurs the scene objects too near or too far away to create the sense of out of focus. You can press "B" during play to toggle the effect on and off. Shader **depthfield** (under Assets\\Shaders\\depth) is responsible for encoding depth information of scene objects into a render target texture, which will be blurred twice by shader **blur** under Assets\\Shaders\\imageeffects.

### Depthfield
The first part of this shader is a common phong model lighting calculation. At the end of the shader, each fragment is flagged whether it should be blurred via its z coordinate in eye space and such information is stored in the fragment’s alpha channel. In the subsequent rendering process, the blurring effect is applied based on the flag.

### Blur
Blur an input texture with 5 by 5 gaussian filter.

## Scene: environmentmapping
This scene implements environment mapping through reflection and refraction. This effect consists of two shaders, **environment** and **skybox** (Assets\\Shaders\\environmentmapping).

### Environment
This shader takes a cube map of a street view as input and computes a reflection vector and a refraction vector. These two vectors are then used for sampling the map and texturing the spaceship, thus achieving the effect.

### Skybox
As the name suggests, this shader takes care of rendering the background (environment) of the scene in a manner similar to how a skybox is generated.

## Scene: imageeffects
Four image effects based on screen space filtering have been implemented in this scene, namely, **edges**, **blur**, **sharpen** and **motionblur**, which are also the names of the four corresponding shaders (located under Assets\Shaders\imageeffects). To see a specific effect, simply select it from the option group in the top right corner.

### Blur
Same shader used in Scene *depth*. There is a slidebar called *Enabling Blurring* in the material *imageeffects* of the game object *Fullscreenquad*, which can toggle the effect on and off.

### Sharpen
There is a slidebar called *Enabling Shapening* in the material *imageeffects* of the game object *Fullscreenquad*, which can toggle the effect on and off.

### Motionblur
Simliar to the aforementioned effects, the blur direction, number of samples and distance can be changed via shader properties in the material *imageeffects* of the game object *Fullscreenquad*.

## Scene: normalmapping
Normal mapping is visited in this scene, which gives the barrel more visual details. The shader **normalmapping** is responsible for realising this effect, which is located under Assets\\Shaders\\texturemapping. Similarly to the previous *basiclighting* scene, the *Light_dir* game object represents the direction of the light source in the scene, which is passed into the shader at each frame. Therefore, you can manually change the orientation of *Light_dir* in the scene window during play and observe the shading result changes accordingly.

## Scene: proceduraltexture
This scene contains a quad game object whose checkboard texture is procedurally generated in the shader **checkerboard** (under Assets\\Shaders\\texturemapping). This shader also implements a wobbling effect for the texture, which reacts to the mouse position.

## Scene: textureblending
This scene demonstrates texture mapping using HLSL. The shader, **daynight** (located under Assets\\Shaders\\texturemapping), samples the day and the night texture and blends them together linearly based on the system time.

## Scene: vertexdeform
This is a pulsating effect which has the spaceship change between a bloating state and its normal form over time. There is only one new shader in this scene, **pulsate**, which can be found under Assets\\Shaders\\vertexdeform.

### Pulsate
Besides the material properties for lighting calculation, two new properties have been added as input to this shader, *Time param* and *Extent*. The former is a result of sine function so it is bouncing between 0 and 1 for linearly interpolating the two spaceship states. The latter controls the bloating extent in object space unit. Each vertex of the spaceship moves along the direction of its normal to achieve this effect.

## Scene: wavysurface
In this scene, I employ three cosine waves to alter the height (y coordinate) of vertices of a tessellated plane. The result is a simulation of a complex wave. The shader written for this scene is **wavy** (under Assets\\Shaders\\vertexdeform).

### Wavy
The shader exposes the wave direction, frequency, amplitude and speed of three cosine waves through material property, which allow viewers to alter the appearance of the final composite wave. The 3 directions are expressed in degree while the 3 amplitudes are in object space unit. Apart from calculating and adding the height of vertices in terms of each wave, this shader also update the normals at each frame to make the lighting correct.
