require_relative 'base_scrapper'
require 'nokogiri'
require 'open-uri'
require_relative 'table'
require_relative 'github_worker'
require_relative 'does_not_include'

class GithubRepoScrapper < BaseScrapper

  attr_accessor :user_list, :table

  def initialize(user_list, workers_count = 3)
    super workers_count
    self.user_list = user_list
    self.headers['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2062.94 Safari/537.36'
    @table = Table.new({})
    self.data = @table
  end

  def execute_scrapper
    puts self.user_list
    self.user_list.each do |user|
      self.get_user_repos user
    end
    self.run_workers
  end

  def get_user_repos(user)
    self.headers['Referer'] = "https://github.com/#{user}"
    self.headers['Host'] = 'github.com'

    uri = "https://github.com/#{user}?tab=repositories"
    repo_page = Nokogiri::HTML(open(uri, self.headers))
    selected_repos = repo_page.css('a').map{|anchor| anchor['href']}.select { |link| link.start_with? "/#{user}/" and link.does_not_include? 'stargazers' and link.does_not_include? 'network'}
    self.add_links selected_repos
  end

end


#Demo
user_list = ['tacaswell', 'bossiernesto', 'flbulgarelli']
scrapper = GithubRepoScrapper.new(user_list, 3)
scrapper.execute_scrapper

