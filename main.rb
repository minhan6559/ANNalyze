require 'ruby2d'
require 'savio'
require_relative './UI/MainMenu.rb'
require_relative './ANN/Model.rb'

set title: "ANNalyze"
set width: 1250
set height: 720
set background: "#252526"
 
if __FILE__ == $0
    render_main_menu()
    # create_button('./images/BuildingScreen/Start_button.png', 221, 297, 266.0 /2, 58)
    show()
end