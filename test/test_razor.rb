require 'helper'

class TestWebshaver < Test::Unit::TestCase
  context "A Basic pageflow" do

    should "Be able to load up firefox" do
      assert_equal(razor.webdriver.class, Watir::Browser)
    end
    should "Be able to load a page" do
      razor.goto "http://www.google.com"
      assert_equal(razor.url, "http://www.google.com/")
    end
    should "Be able to submit" do
      razor.goto "http://www.google.com"
      razor.enter_text "//input[@name='q']", "Buy"
      razor.submit
      assert razor.url =~ /q=Buy/
    end
    should "Be able to shave" do
      razor.goto "http://www.google.com/search?q=Buy"
      r = razor.shave do
        value(:stats, "//p[@id='resultStats']") do |x|
          x.text.scan(/of about (.+) for/)[0][0]
        end
        array :suggestions, "//table[@id='brs']/tbody/tr/td" do |x|
          x.text
        end
      end

      assert_equal r[:stats],"1,790,000,000"
      assert r[:suggestions].length > 0
    end
  end
end

