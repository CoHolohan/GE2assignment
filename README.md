# GE2Assignment - Lola the dog

### Name  
Cormac Holohan  

### Student Number  
C22363913  

### Class Group  
Tu/856

### GitHub  
[https://github.com/CoHolohan/GE2assignment](https://github.com/CoHolohan/GE2assignment)

---

## Video
https://youtu.be/ooi7YS1BUjk
## Screenshots

Lola

<img width="405" height="305" alt="image" src="https://github.com/user-attachments/assets/3fbda02b-db75-49a9-b033-666299e5069c" />

Garden

<img width="1316" height="543" alt="image" src="https://github.com/user-attachments/assets/21208f86-e561-4542-845e-a3f2995c1e6a" />

Main Scene Navigation mesh

<img width="1228" height="513" alt="image" src="https://github.com/user-attachments/assets/c92e7b55-07ba-47ac-8d37-434338cfd582" />


---

## Description of the Project
This project is a virtual dog simulation built in Godot 4, featuring a dog named Lola who lives in a garden environment.  
The player can walk around the garden and interact with Lola, whose behaviour is driven by a Finite State Machine (FSM) and a Navigation Mesh.
 
Lola has three core needs, **hunger**, **thirst**, and **happiness**, which decrease naturally over time. She will autonomously navigate to her food or water bowl when her needs drop low enough, and her happiness increases when she follows the player around the garden.  
The game features particle effects, bark sound effects recorded from a real dog, and CSG-based animations.


---

## How It Works
 
- Lola is controlled by a **Finite State Machine (FSM)** with five states: **Idle**, **Wandering**, **Curious**, **Thirsty**, and **Hungry**.
- A **Navigation Mesh** is used to handle pathfinding around the garden environment.
- Three variables — **hunger**, **thirst**, and **happiness** — decrease passively over time.
- When hunger or thirst fall below a threshold, Lola transitions to the relevant state and navigates to the food or water bowl to refill the stat.
- When the player is nearby, Lola follows them, which increases her happiness.
- Lola barks after eating or drinking, and also barks at random intervals during gameplay.
- **Particle effects** trigger when Lola eats or drinks.
- Animations were created using **CSG (Constructive Solid Geometry)** objects.
- Bark sound effects were recorded from a real dog.
- There are 3 scenes to the project, the garden, which is how the environment was built(eg, the fences, the housees, the food and water bowls, the grass and the doghouse).
- Then the dog scene, where I built the dog using various csg shapes and the animations were made their too, and the main scene where it all comes together.
- The environment was built using some free open source models from free 3D, and some self made objects, such as the fence, doghouse, bowls and dog.


---

## List of Classes / Assets in the Project

| Class / Asset | Source |
|--------------|--------|
| Dog_needs.gd | Self written / AI assistance |
| dog_fsm.gd | Self written / AI assistance |
| dog_states.gd | Self written / AI assistance |
| dog_animation.gd | Self written / AI assistance |
| dog_sounds.gd | Self written |
| player.gd | Self written |
| Garden environment | Self built / Open Source models |
| Bark sound effects | Recorded from a real dog |
| Background Noise | Open source from free sound |


---

## References

1. Godot Engine Documentation – https://docs.godotengine.org  
2. FreeSound – https://freesound.org  
3. Free3D – https://free3d.com/
4. Godot Navigation Mesh Documentation – https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_introduction_3d.html  

---

## What I Am Most Proud Of in the Assignment
I am most proud of the Finite State Machine implementation and how naturally it drives Lola's behaviour.  
Seeing the dog autonomously manage her own needs, navigating to her bowl when hungry or thirsty, following the player when happy, made the simulation feel genuinely alive.  
Using real dog bark recordings added a lot of personality that I think really elevated the project.

---

## What I Learned
Through this project, I learned how to:
 
- Implement a Finite State Machine in Godot 4 for believable NPC behaviour
- Use a Navigation Mesh for autonomous pathfinding in a 3D environment
- Manage game variables that drive AI state transitions
- Use particle systems for visual feedback
- Work with audio in Godot, including integrating real-world recordings
- Build 3D environments and animations using CSG objects


---
