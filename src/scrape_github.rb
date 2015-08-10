require_relative 'base_scrapper'
require 'nokogiri'
require 'open-uri'
require_relative 'table'

class GithubRepoScrapper < BaseScrapper

  attr_accessor :user_list, :table

  def initialize(user_list, workers_count = 3)
    super workers_count
    self.user_list = user_list
    self.headers['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2062.94 Safari/537.36'
    @table = Table.new({})
  end

  def execute_scrapper
    puts self.user_list
    self.user_list.each do |user|
      self.get_user_repos user
    end
    self.run_workers
  end

  def run_workers
    (0..self.workers_count-1).each do
      thread = Thread.new { run_worker(self.queue_link, self.headers, @table)}
      self.workers_list.push thread
    end
    self.workers_list.each do |thread|
      thread.join
    end
  end

  def get_user_repos(user)
    self.headers['Referer'] = "https://github.com/#{user}"
    self.headers['Host'] = 'github.com'

    uri = "https://github.com/#{user}?tab=repositories"
    repo_page = Nokogiri::HTML(open(uri, self.headers))
    selected_repos = repo_page.css('a').map{|anchor| anchor['href']}.select { |link| link.start_with? "/#{user}/"}
    self.add_links selected_repos
  end

end

def run_worker(queue_link, headers, data)
  table = data

  while true
    link = queue_link.pop
    if link.eql? 'STOP_WORKER'
      puts "Stopping worker id #{Thread.current.object_id}"
      Thread.current.kill
    end

    complete_link = "https://github.com#{link}"
    puts "Getting link #{complete_link} by worker id: #{Thread.current.object_id}"
    repo = Nokogiri::HTML(open(complete_link, headers))
    repo.xpath('//span[@class="lang"]').each do | method_span |
      language = method_span.content
      if table.get(language).nil?
        table.put language, 1
      else
        table.accum language, 1
      end
    end

    directory_name = 'repoInfo'
    #create directory if it does not exist
    Dir.mkdir(directory_name) unless File.exists?(directory_name)

    #bureocracy
    filename = link.split('/').last
    filename = "#{directory_name}/#{filename}.html"

    File.open(filename, 'w') { |file| file.write(repo.to_html) }
    puts "Done saving #{filename}"
  end
end

#Demo
user_list = ['pwuertz', 'tacaswell', 'flbulgarelli']
scrapper = GithubRepoScrapper.new(user_list, 3)
scrapper.execute_scrapper

