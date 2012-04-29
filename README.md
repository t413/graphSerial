graphSerial
===========

Fancy real time charts from serial input (just USB HID for now). Auto scaling, mutiple input support, RegEx (regular expression) input matching. 

See what I mean in [this video](http://www.youtube.com/watch?feature=player_detailpage&list=UUPYCZmZIbfq260t8R1iqUtA&v=6ypRadypV1A#t=123s). I'm showing off the control system in [another project of mine](https://github.com/t413/sedRobotController). 

##How to use:
- Get something that'll output USB HID, or mod the program to take whatever data you have.
- Let's say your µC outputs `val=20, hi:40 and 50.2;` every 10 ms. Awesome. Put `val=([0-9]+), hi:([0-9]+) and ([-+]?[0-9]*\.?[0-9]+);` in for your RegEx field and hit return. Magic. 
- This expression has 3 input groups (things in parenthesis). Three lines will appear and start graphing themselves. Sweet. 
- Anything that doesn't match this RegEx will be output to the NSLog debug console. Future versions will handle this better (put it in a nice floating box or something).

The chart class `qGraph.m` (quick graph) could be very useful to other peoples' projects. 

In the future I'd like to add more robust RegEx parsing, more customizable plotting, more input options, and some storage/playback support. For now it's just handy and is customizable via changing the code itself. 