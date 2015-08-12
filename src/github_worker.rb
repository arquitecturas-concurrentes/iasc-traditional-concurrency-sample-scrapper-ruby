def run_worker(queue_link, headers, data)
  table = data

  while true
    link = queue_link.pop
    if link.eql? 'STOP_WORKER'
      puts "Stopping worker id #{Thread.current.object_id}"
      Thread.current.kill
    end

    complete_link = "https://github.com#{link}"
    puts "Getting link #{complete_link} by worker id: #{Thread.current['id']}"
    repo = Nokogiri::HTML(open(complete_link, headers))
    repo.xpath('//span[@class="lang"]').each do | method_span |
      language = method_span.content
      table.get_or_accum(language, 1, 1)
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