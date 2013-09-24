require 'benchmark'
require 'pp'

#
# Program to generate sample movie dataset
# @author ashrith (ashrith at cloudwick dot com)
# 

class Movie
  MOVIE_GENRE = {
    :action => 10,
    :comedy => 10,
    :family => 10,
    :history => 10,
    :adventure => 10,
    :horror => 10,
    :documentary => 10,
    :drama => 10,
    :romance => 10,
    :scifi => 10
  }

  def initialize(movie_titles)
    @data = parse_to_hash(movie_titles)
  end

  def parse_to_hash(file)
    hash = {}
    File.open(file, 'r').each_line do |line|
      id, year, name = line.split(',', 3)
      year = 0 if year == 'NULL'
      hash[id] = { :year => year, :name => name }
    end
    hash
  end

  def gen
    rid = (Kernel.rand(@data.length)+1).to_s
    # movieid, moviename, releaseyear, length_of_movie, movie_genre
    [rid, 
      @data[rid][:name], 
      @data[rid][:year], 
      Kernel.rand(50..90), 
      pick_weighted_key(MOVIE_GENRE)
    ]
  end

  private

  def pick_weighted_key(hash)
    total = 0
    hash.values.each { |t| total += t }
    random = Kernel.rand(total)

    running = 0
    hash.each do |key, weight|
      if random >= running and random < (running + weight)
        return key
      end
      running += weight
    end

    return hash.keys.first
  end   
end


class Person
  GENDERS = {
    :male => 56,
    :female => 44
  }

  @@lastnames = %w(ABEL ANDERSON ANDREWS ANTHONY BAKER BROWN BURROWS CLARK
                   CLARKE CLARKSON DAVIDSON DAVIES DAVIS DENT EDWARDS GARCIA
                   GRANT HALL HARRIS HARRISON JACKSON JEFFRIES JEFFERSON JOHNSON
                   JONES KIRBY KIRK LAKE LEE LEWIS MARTIN MARTINEZ MAJOR MILLER
                   MOORE OATES PETERS PETERSON ROBERTSON ROBINSON RODRIGUEZ
                   SMITH SMYTHE STEVENS TAYLOR THATCHER THOMAS THOMPSON WALKER
                   WASHINGTON WHITE WILLIAMS WILSON YORKE)

  @@male_first_names =
    %w(ADAM ANTHONY ARTHUR BRIAN CHARLES CHRISTOPHER DANIEL DAVID DONALD EDGAR
       EDWARD EDWIN GEORGE HAROLD HERBERT HUGH JAMES JASON JOHN JOSEPH KENNETH
       KEVIN MARCUS MARK MATTHEW MICHAEL PAUL PHILIP RICHARD ROBERT ROGER RONALD
       SIMON STEVEN TERRY THOMAS WILLIAM)

  @@female_first_names =
    %w(ALISON ANN ANNA ANNE BARBARA BETTY BERYL CAROL CHARLOTTE CHERYL DEBORAH
       DIANA DONNA DOROTHY ELIZABETH EVE FELICITY FIONA HELEN HELENA JENNIFER
       JESSICA JUDITH KAREN KIMBERLY LAURA LINDA LISA LUCY MARGARET MARIA MARY
       MICHELLE NANCY PATRICIA POLLY ROBYN RUTH SANDRA SARAH SHARON SUSAN
       TABITHA URSULA VICTORIA WENDY)

  def gen
    gender = pick_weighted_key(GENDERS)
    cname = case gender
            when :male
              male_name
            when :female
              female_name
            end
    cname
  end

  private
  
  def initial
    letters_arr = ('A'..'Z').to_a
    letters_arr[rand(letters_arr.size)]
  end

  def lastname
    @@lastnames[rand(@@lastnames.size)]
  end

  def female_name
    "#{@@female_first_names[rand(@@female_first_names.size)]} #{lastname}"
  end

  def male_name
    "#{@@male_first_names[rand(@@male_first_names.size)]} #{lastname}"
  end

  def pick_weighted_key(hash)
    total = 0
    hash.values.each { |t| total += t }
    random = Kernel.rand(total)

    running = 0
    hash.each do |key, weight|
      if random >= running and random < (running + weight)
        return key
      end
      running += weight
    end

    return hash.keys.first
  end  
end

class Customers
  attr_reader :cid, :cname, :user_active, :time_watched, :paused_time, :rating

  ACTIVE_INACTIVE = {
    0 => 80,
    1 => 20
  }

  RATINGS = {
    -1  => 30,
    5   => 5,
    4.5 => 15,
    4   => 15,
    3.5 => 20,
    3   => 5,
    2.5 => 5,
    2   => 2.5,
    1   => 2,
    0   => 0.5
  }

  PAUSED_TIME = {
    0 => 80,
    1 => 20
  }

  def initialize(cid, cname, movie_total_time)
    @cid = cid
    @cname = cname
    @user_active = user_active?
    @time_watched = gen_date(Time.local(2010, 1, 1), Time.now)
    @movie_total_time = movie_total_time
    @paused_time = played_time
    @rating = gen_rating
  end

  def to_s
    "#{@cid} <=> #{@cname} <=> #{@user_active} <=> #{@time_watched} <=> " + 
    "#{@paused_time} <=> #{@rating}"
  end 

  private

  def gen_rating
    pick_weighted_key(RATINGS)
  end

  def user_active?
    pick_weighted_key(ACTIVE_INACTIVE)
  end

  def gen_date(from=0.0, to=Time.now)
    Time.at(from + rand * (to.to_f - from.to_f))
  end

  def played_time
    paused_time = pick_weighted_key(PAUSED_TIME)
    case paused_time
    when 0
      return 0
    when 1
      return Kernel.rand(0..@movie_total_time)
    end
  end   

  def pick_weighted_key(hash)
    total = 0
    hash.values.each { |t| total += t }
    random = Kernel.rand(total)

    running = 0
    hash.each do |key, weight|
      if random >= running and random < (running + weight)
        return key
      end
      running += weight
    end

    return hash.keys.first
  end
end

def run!(file_path, file_size_in_mb)
  @movie = Movie.new(
    File.expand_path(File.dirname(__FILE__) + '/movie_titles.csv')
  )
  @person = Person.new
  @cust = {}
  @total_customers = 1_000

  Benchmark.bm(50) do |bm|
    bm.report("generate hash of #{@total_customers} custormers") do
      @total_customers.times do |i|
        @cust[i + 1] = @person.gen
      end
    end
  end

  time = Benchmark.measure do
    file_size = 0
    File.open(File.expand_path(file_path), 'w') do |file|
      while file_size < file_size_in_mb.to_i * 1048576 # bytes in 1 MB
        cid = Kernel.rand(1..@total_customers)
        cname = @cust[cid]
        movie_info = @movie.gen
        customer = Customers.new(cid, cname, movie_info[3])
        string = "#{customer.cid}, #{customer.cname}, " + 
          "#{customer.user_active}, #{customer.time_watched}, "+
          "#{customer.paused_time}, #{customer.rating}, " +
          "#{movie_info[0]}, #{movie_info[1].strip}, #{movie_info[2]}, " +
          "#{movie_info[3]}, #{movie_info[4]}\n"        
        file.print string
        file_size += string.size
        mb = 1024.0 * 1024.0
        print "\rSize (MB): #{(file_size/mb).round(2)}"
      end
    end
    puts
  end

  puts "Time took to generate records: #{time}"
end

if __FILE__ == $0
  printf "Enter file size (MB): "
  file_size_in_mb = gets.chomp

  printf "Enter the file path: "
  file_path = gets.chomp

  raise "bad file size" unless file_size_in_mb =~ /^\d+$/
  dir_path = File.dirname(File.expand_path(file_path))
  unless File.directory?(dir_path) && File.writable?(dir_path)
    raise "bad file path"
  end

  run! file_path, file_size_in_mb
end