# This file is the entry point of the program.
# It requires the Model class from the ANN module and the ScreenEngine class from the UI module.
# It then calls the start_window method to start the program.
require_relative './lib/ANN/Model.rb'
require_relative './lib/UI/ScreenEngine.rb'

if __FILE__ == $0
    start_window()
end