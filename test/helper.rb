require 'rubygems'
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'razor'

RAZOR = Razor.new(:blade => :firefox)

def razor
  RAZOR
end

class Test::Unit::TestCase
end

