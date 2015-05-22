require 'capybara/poltergeist'

module GoogleSearchByImageParser
  class << self
    def import_task
      data = Hashie::Mash.new(JSON.parse(File.read(Rails.root.join('doc', 'pic.json'))))
      pics = data.data.map(&:pic)

      datas = []

      crawler = Crawler.new
      pics.each_with_index do |pic, i|
        print "#{i}, "
        next if not Image.find_by(url: data.data[i].pic).nil?

        images = crawler.search_by(pic)
        # datas << data.data[i]
        # datas.last.images = images
        image = data.data[i]
        image.images = images
        Image.create(
          url: image.pic,
          gender: image.gender,
          age: image.age,
          sid: image.sid,
          alikes: image.images
        )

      end

      # images = crawler.search_by(pics[0..-1])
      # binding.pry
    end

    def update_image(image)
      crawler = Crawler.new
      alikes = crawler.search_by(image.url)
      image.alikes = alikes
      image.save
    end

  end

  class Crawler
    include Capybara::DSL
    def initialize
      Capybara.register_driver :poltergeist_debug do |app|
        driver = Capybara::Poltergeist::Driver.new(app, {
          # debug: true,
          # js_errors: true
        })
        # config request user agent, simple Zzzzzz
        driver.headers = { "User-Agent" => "Mozilla/5.0 (X11; Linux x86_64; rv:7.0.1) Gecko/20100101 Firefox/7.0.1" }
        driver
      end
      Capybara.current_driver = :poltergeist_debug
      @base_url = "https://www.google.com/searchbyimage?hl=en&site=search&image_url="
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
      images = doc.css('a').select {|d| d && d[:href] && d[:href].include?('http://www.google.com/imgres') }.map do |d|
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
