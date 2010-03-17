$: << File.dirname(__FILE__)+'/../../watir-webdriver/lib/'
require 'watir-webdriver'
require 'thread'

class Razor
  attr_reader :webdriver
  def initialize(options={})
    @options = options
    @options[:timeout_before_refresh] ||= 60*5 #5 minutes in seconds
    @options[:blade] ||= :firefox
    
    # pass any extra options to watir, removing razor options
    
    @webdriver = Watir::Browser.new(@options[:blade], watir_options)
    
    ObjectSpace.define_finalizer( self, self.class.finalize(@webdriver) )
  end
  def watir_options
    watir = @options.dup
    watir.delete(:timeout_before_refresh)
    watir.delete(:blade)
    watir
  end
  def goto(url)
    begin
      Timeout::timeout(@options[:timeout_before_refresh]) do
        puts "going to #{url.inspect}"
        @webdriver.goto(url)
      end
    rescue Timeout::Error => e
      puts "It took longer than #{@options[:timeout_before_refresh]} to load #{url}.  Refreshing browser"
      @webdriver.refresh
      retry
    end
  end
  # Restarts the browser.  Useful in a variety of circumstances,
  # such as internet loss, a user closing razor's browser, etc
  def reset!
    puts "Error was significant.  creating a new browser"
    temp_url = url
    puts "Found url = #{url.inspect}"
    @webdriver.close
    @webdriver = Watir::Browser.new(@options[:blade], watir_options)
    goto(temp_url)
  end
  def url
    @webdriver.url
  end
  def enter_text(xpath, text)
    @webdriver.text_field(:xpath, xpath).set text
  end
  def submit
    @webdriver.form(:xpath, "//form").submit
  end
  def element(xpath)
    @webdriver.element_by_xpath(xpath)
  end
  def input(xpath)
    @webdriver.input(:xpath, xpath)
  end
  def click(xpath)
    @webdriver.element_by_xpath(xpath).click
  end
  def shave(options={}, &block)
    Shave.new(@webdriver, options, &block).evaluate
  end
  def close
    @webdriver.close
  end

  def self.finalize(webdriver)
    proc { webdriver.close }
  end
end

class Shave
  def initialize(webdriver, options, &block)
    @webdriver = webdriver
    @options = options
    @options[:number_of_steps]||=10
    @options[:step_time]||=0.5
    @options[:validation_limit]||=10
    @options[:flush_results_between_pages] ||= false
    @arrays = []
    @values = []
    self.instance_eval &block
  end

  def validate(&block)
    @validator = block
  end

  def next_page(xpath, &block)
    @next_page_xpath = xpath
    @next_page_block = block
  end

  def value(name, xpath, &block)
    @values << [name,xpath,block]
  end

  def array(name, xpath, &block)
    @arrays << [name,xpath,block]
  end
  
  def with_results(&block)
    @with_results = block
  end

  def evaluate
    result = {}
    validation_attempts = 0
    while(true) do
      #page scrape
      page_results = evaluate_values.merge(evaluate_arrays)
      if @options[:flush_results_between_pages] && validation_attempts == 0
        new_result = page_results
      else
        new_result = merge_values(result, page_results)
      end
      
      #next page
      next_page = nil
      unless @next_page_xpath == nil
        next_page = @webdriver.element_by_xpath(@next_page_xpath)

        unless next_page.exists?
          result = new_result
          @with_results.call(result) unless @with_results == nil
          break
        end
      end

      # validation
      if @validator != nil
        unless @validator.call(page_results)
          validation_attempts += 1
          raise "Validation limit of #{@options[:validation_limit]} reached for url #{@webdriver.url}" if(validation_attempts >= @options[:validation_limit])
          sleep @options[:step_time]
          next
        end
      end
      validation_attempts = 0
      
      result = new_result
      @with_results.call(result) unless @with_results == nil
      
      # goto next page
      break if @next_page_xpath == nil
      @next_page_block.call(next_page) unless @next_page_block.nil?
      next_page.click
    end
    result
  end  

private

  # Two hashs of {:test => [1]} {:test => [2,3]}
  # become: {:test => [1,2,3]}
  def merge_values(f, s)
    result = {}
    f.each do |name, value|
      result[name] = value + (s[name] || []) if(value.is_a? Array)
    end
    s.each do |name, value|
      result[name] ||= value
    end
    result
  end

  # Because of the fact that selenium doesn't wait for the page to load,
  # we continuously poll every :step_time seconds for a :number_of_steps
  def evaluate_values
    result = {}
    @values.each do |name, xpath, block|
      try_and_sleep_on_fail do
        result[name] = process_value(xpath,block)
      end
    end
    result
  end

  def process_value(xpath, block)
    element = @webdriver.element_by_xpath(xpath)
    block == nil ? element : block.call(element)
  end

  def try_and_sleep_on_fail
    success = false
    (0...@options[:number_of_steps]).each do |step|
      begin
        x = yield
        if(x.is_a?(Array) && x.length==0)
          puts "Sleeping on step #{step}"
          sleep @options[:step_time]
          #if step % 2 == 1
            #puts "Attempting refresh"
            #@webdriver.refresh
          #end
          next
        end
        success=true
        break
      rescue Exception
        puts "exception sleeping on step #{step}"
        @webdriver.refresh
        sleep @options[:step_time]
        retry
      end
    end
    yield unless success
  end

  def evaluate_arrays
    result={}
    @arrays.each do |name, xpath, block|
      try_and_sleep_on_fail do
        result[name] = process_array(xpath, block)
      end
    end
    result
  end

  def process_array(xpath, block)
    @webdriver.elements_by_xpath(xpath).map do |element|
      block == nil || element == nil ? element : block.call(element)
    end
  end

end

