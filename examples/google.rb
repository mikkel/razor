require 'rubygems'

$: << File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))
require 'razor'

def stats_for(keyword)
  razor = Razor.new(:blade => :firefox)
  razor.goto "http://www.google.com"
  razor.enter_text "//input[@name='q']", keyword
  #razor.submit
  razor.click "//input[@value='Google Search']"
  results = razor.shave do
    value(:stats, "//p[@id='resultStats']") do |x|
      x.text.scan(/of about (.+) for/)[0][0]
    end
    array :suggestions, "//table[@id='brs']/tbody/tr/td" do |x|
      x.text
    end
  end
end

p stats_for("Buy")

