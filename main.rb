require 'ruby2d'
require 'savio'
require 'numo/narray'
require_relative './UI/MainMenu.rb'

set title: "ANNalyze"
set width: 1250
set height: 720
set background: "#252526"
 
if __FILE__ == $0
    render_main_menu()
    show()
end