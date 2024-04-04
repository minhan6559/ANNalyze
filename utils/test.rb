require 'ruby2d'

window1 = Window.new(width: 640, height: 480)
window1.set background: 'red'

a = Sprite.new(
    './images/BuildingScreen/Building_screen_background.png',
    x: 0, y: 0, clip_width: 22
)

p a.clip_width

window1.show