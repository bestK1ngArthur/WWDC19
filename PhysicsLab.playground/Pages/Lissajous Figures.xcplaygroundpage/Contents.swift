/*:
 # Lissajous Figures:
 
 [👈 To information](@previous)
 
 This experiment shows a simulation of the movement of an object in a system of 4 springs.
 
 To start the experiment, press the start button, pull and release the mass point.
 
 ### Make sure the assitant editor and live view are selected:
 ![Assitant Editor](assistantEditor.png)
 */

import UIKit
import PlaygroundSupport

// Create experiment
let lissajousFigures = LissajousExperiment()

/*:
 You can play with spring stiffness and environmental viscosity and get pictures like this:
 
  ![Example of Figure](figure.jpg)
 */

lissajousFigures.viscosity = 1

lissajousFigures.topSpringStiffness = 50
lissajousFigures.bottomSpringStiffness = 50
lissajousFigures.leftSpringStiffness = 10
lissajousFigures.rightSpringStiffness = 10

/*:
 You can change the colors and other UI characteristics of the springs.
 */

lissajousFigures.drawingLineColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
lissajousFigures.drawingLineWidth = 5

lissajousFigures.springsOpacity = 0.5
lissajousFigures.springsLineColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
lissajousFigures.springsLineWidth = 4

/*:
 You can set the theme color of lab.
 */

// Create lab
let physicsLab = PhysicsLab(themeColor: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))

// Set experiment
physicsLab.experiment = lissajousFigures

PlaygroundPage.current.liveView = physicsLab.liveView
