class Table
  def initialize(hash)
    @hash = hash
    @mutex = Mutex.new
  end

  def put(key, value)
    @mutex.synchronize do
      @hash[key] = value
    end
  end

  def get(key)
    @mutex.synchronize do
      @hash[key]
    end
  end

  def delete(key)
    @mutex.synchronize do
      @hash.delete key
    end
  end

  def accum(key, delta)
    @mutex.synchronize do
      @hash[key] += delta
    end
  end

  def get_or_accum(key, delta, initial)
    @mutex.synchronize do
      if self.get(key).nil?
        self.put(key, initial)
      else
        self.accum(key, delta)
      end
    end
  end
end
