require 'redis'
require 'hiredis'
require 'pg'
require './generator.rb'

begin
  @movie = Movie.new('localhost', 5432, 'movies', 'movies', 'ashrith', '')
  Benchmark.bm(50) do |bm|
    loop = 1000000
    bm.report("generating #{loop} movie random from DB lookup") do
      loop.times do
        @movie.gen
      end
      # p Person.new.gen
    end
  end
rescue PG::ConnectionBad => e
  puts $!
end

@person = Person.new

# Profile generating 1 million custormer records into hash
# and meausre 1M lookups
time = Benchmark.measure do
  @final = {}
  1_000_000.times do |i|
    @final[i+1000] = @person.gen
  end
end
puts "Time to insert 1 million entries to ruby hash took: #{time}"

time = Benchmark.measure do
  1_000_000.times do 
    @final[Kernel.rand(1000..1001000)]
  end
end
puts "Time to lookup entires from hash 1 million times took: #{time}"

@redis = Redis.new(:host => 'localhost', :port => 6379, :driver => :hiredis)
time = Benchmark.measure do
  1_000_000.times do |i|
    @redis.hset('cust', 1000+i, @person.gen)
  end
end
puts "Time ti insert 1 million records to redis took: #{time}"
time = Benchmark.measure do
  1_000_000.times do |i|
    @redis.hget('cust', 1000+i)
  end
end
puts "Time to fetch 1M records from redis took: #{time}"
