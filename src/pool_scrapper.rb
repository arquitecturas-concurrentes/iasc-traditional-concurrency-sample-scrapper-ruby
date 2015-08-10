require_relative 'base_scrapper'
require_relative 'pool'

class PoolScrapper < BaseScrapper

  attr_accessor :pool

  def initialize(workers_count = 3)
   super workers_count
   self.pool = Pool.new(workers_count)
  end

  def run_workers
    self.pool.schedule do
      run_worker(self.queue_link, self.headers, self.data)
    end

    at_exit { self.pool.shutdown }
  end

end