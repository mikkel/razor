$: << File.dirname(__FILE__)+'/../../watir-webdriver/lib/'
require 'watir-webdriver'

class Razor
  attr_reader :webdriver
  def initialize(options={})
    @webdriver = Watir::Browser.new(options.delete(:blade) || :firefox, options)
    ObjectSpace.define_finalizer( self, self.class.finalize(@webdriver) )
  end
  def goto(url)
    @webdriver.goto(url)
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

  def next_page(xpath)
    @next_page_xpath = xpath
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
      if @options[:flush_results_between_pages]
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
    @options[:number_of_steps].times do
      begin
        x = yield
        if(x.is_a?(Array) && x.length==0)
          sleep @options[:step_time]
          next
        end
        success=true
        break
      rescue Exception
        sleep @options[:step_time]
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

