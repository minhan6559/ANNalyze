print "Integer please: " 
input = gets
user_num=Integer(input) rescue false 
if user_num 
    puts "You entered #{user_num}"
end