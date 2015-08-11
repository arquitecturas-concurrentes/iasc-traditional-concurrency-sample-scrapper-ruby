require 'nokogiri'
require 'thread'
require_relative 'abstract'

class BaseScrapper
  extend Abstract

  attr_accessor :queue_link, :workers_list, :workers_count, :headers, :data
  abstract_methods :execute_scrapper

  def initialize(workers_count = 3)
    self.queue_link = Queue.new
    self.workers_count = workers_count
    self.workers_list = Array.new
    self.headers = {}
    self.data = {}
  end

  def add_links links
    links.each do |link|
      self.queue_link << link
    end
  end

  def add_stop_worker_instructions
    self.workers_count.times do
      self.queue_link << 'STOP_WORKER'
    end
  end

  def run_workers
    self.workers_count.times do |counter|
      thread = Thread.new do
        Thread.current['id'] = counter
        run_worker(self.queue_link, self.headers, self.data)
      end

      self.workers_list.push thread
    end
    self.workers_list.each do |thread|
      thread.join
    end
  end

end

def run_worker(queue_link, headers, data)

end
