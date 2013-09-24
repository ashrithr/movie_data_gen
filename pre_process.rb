writer = File.open('/Users/ashrith/Downloads/movie_titles.csv', 'w')
File.open('/Users/ashrith/Downloads/movie_titles.txt', 'r').each_line do |line|
  id, year, name = line.encode('UTF-8', :invalid => :replace).split(',', 3)
  year = 0 if year == 'NULL'
  writer.write("#{id},#{year},\"#{name.strip}\"\n")
  puts "#{id},#{year},\"#{name.strip}\""
end
writer.close