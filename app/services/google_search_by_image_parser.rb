require 'capybara/poltergeist'

module GoogleSearchByImageParser
  class << self
    def prepare_test
      data = Hashie::Mash.new(JSON.parse(File.read(Rails.root.join('doc', 'pic.json'))))
      pics = data.data.map(&:pic)

      errors = []

      crawler = Crawler.new
      pics[0..50].each_with_index do |pic, i|
        print "#{i}, "
        images = crawler.search_by(pic)
        if images.count > 0
          errors << data.data[i]
          errors.last.images = images
        end
      end
      # images = crawler.search_by(pics[0..-1])
      # images = crawler.search_by("https://fbcdn-sphotos-b-a.akamaihd.net/hphotos-ak-xap1/t31.0-8/1271084_10152203108461729_809245696_o.png")
      binding.pry
    end

  end

  class Crawler
    include Capybara::DSL
    def initialize
      Capybara.register_driver :poltergeist_debug do |app|
        Capybara::Poltergeist::Driver.new(app, {
          # debug: true,
          # js_errors: true
        })
      end
      Capybara.current_driver = :selenium
      @base_url = "https://www.google.com/searchbyimage?site=search&image_url="
    end

    def search_by(image_url=nil)
      visit "#{@base_url}#{image_url}"
      # r = IO.popen(["curl", "#{@base_url}#{URI.encode(image_url)}"]).read;
      # url = Nokogiri::HTML(r).css('a')[0][:href]
      # url = Nokogiri::HTML(html).css('a')[0][:href]
      # r = RestClient.get(url)
      # visit url
      _html = html
      if _html.include?('No other sizes of this image found.') || html.include?("找不到這個圖片的其他大小版本")
        return []
      else
        if _html.include? '所有大小'
          click_link '所有大小'
        elsif _html.include? 'All sizes'
          click_link 'All sizes'
        else
          File.open(Rails.root.join('tmp', 'temp.html'), 'w') {|f| f.write(_html)}
          return []
        end
      end
      return parse_search_result(html)
    end

    def parse_search_result(html=nil)
      doc = Nokogiri::HTML(html)
      images = doc.css('a').select {|d| d && d[:href] && d[:href].include?('http://www.google.com.tw/imgres') }.map do |d|
        if d[:href]
          h = URI::decode_www_form(URI(d[:href]).query).to_h;
          if h["imgurl"].include?('x-raw-image')
            nil
          else
            h["imgurl"];
          end
        else
          nil
        end
      end
      images.select {|d| !d.nil?}
    end

  end
end
