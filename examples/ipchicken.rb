require 'rubygems'
$: << File.dirname(__FILE__)+"/../lib"
require 'razor'

razor = Razor.new(:blade => :firefox)
razor.goto "http://www.ipchicken.com"

r = razor.shave do 
  value :ip, "/html/body/table[2]/tbody/tr/td[3]/p[2]/font/b" do |x|
    x.text.scan(/\d+\.\d+\.\d+\.\d+/)
  end
end

razor.close
puts r.inspect
