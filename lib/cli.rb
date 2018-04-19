require_relative "../config/environment.rb"
gem "tty-font"

def welcome
  font = TTY::Font.new(:starwars)
  pastel = Pastel.new


  puts pastel.red(font.write("  WELCOME"))
  puts pastel.red(font.write("                       TO"))
  puts pastel.red(font.write("FLATIRON"))
  puts pastel.red(font.write("           MOVIE"))

  puts pastel.red(font.write("DATABASE"))
  puts pastel.red(font.write("                       CLI"))
  # puts "*"*45
  # puts "|                                     |"
  # puts "|       Welcometo Flatiron Movie      |".upcase
  # puts "|           Database Search           |".upcase
  # puts "|                                     |"
  # puts "="*45
end

def print_list_commands
  puts "*************************************************"
  puts "  # 1. See list of Movies, Directors, Actors."
  puts "  # 2. Search Online for Available movies."
  puts "  # 3. Search Movies by Actor."
  puts "  # 4. Search Movies by Director."
  puts "  # 5. Top 3 rated Movies within our current db."
  puts "  # 6. Top 3 Box Office Movies within current db."
  puts "  # 7. Find Movies by MPAA Rating. Ex. PG-13"
  puts "  # 8. Search Movie by by decade"
  puts "  # 9. Search Movie by by Studio."
  puts "*************************************************"
  puts "Please enter an option from 1-9, 'e' to Exit. "

end

def sub_options
  puts "What would you like to do?"
  puts "A. See List of Movies."
  puts "B. See List of Actors."
  puts "C. See List of Directors.\n"
  puts "**************************************"
  puts "Press (e) to EXIT!"
  puts "Press (r) to RETURN to Main Menu"
  input = gets.chomp.downcase
end

def goodbye
  puts "\n"
  puts "\n"
  puts "*"*45
  puts "|                                           |"
  puts "|         Thank you for stopping bye!!      |".upcase
  puts "|                 GoodBye                   |".upcase
  puts "|                                           |"
  puts "*"*45
  puts "\n"*3
  abort
end

def spacing
  puts "="*40
  puts "\n"
  puts "="*40
  sleep(2)
end

def print_one_list(input)
  case input
    when "a"
      get_movie_info_from_db
    when "b"
      get_actor_info_from_db
    when "c"
      get_director_info_from_db
    when "e"
      goodbye
    when "r"
      options
    else
      input = sub_options
      print_one_list(input)
  end
end

def print_directors_list
  Director.all.each do |direct|
    puts "#{direct.id}. #{direct.name}"
  end
end

def directors_movies
  puts "Please enter a directors number: \n"
  puts "Press (e) to Exit || (r) Return to Main Menu."
  id = gets.chomp
  goodbye if id =="e"
  options if id =="r"
  dm = DirectedMovie.all.where(director_id: id)
  case dm
    when "e"
      goodbye
    when "r"
      options
    when []
      puts print_not_valid_option
      print_directors_list
      directors_movies
    else
      dm.each do |mov|
          Movie.all.each_with_index do |join, index|
            if mov.movie_id == join.id
              puts "#{index +1}. #{join.title}"
            end
          end
      end

  end
end #directors_movies

def options
  print_list_commands
  input = gets.chomp

  case input
    when "e"
      goodbye
    when "1"
      input = sub_options
      print_one_list(input)
    when "2"
      puts "Please enter a movie title: \n"
      input = gets.chomp
      get_movie_info_online(input)
    when "3"
      spacing
      get_actor_info_from_db
      puts "Please enter the actor's id: \n"
      input = gets.chomp
      get_movies_by_actor_id(input)
      spacing
      options
    when "4"
      # 4. Search Movies by Director.
      spacing
      print_directors_list
      puts "\n"
      directors_movies
      # method(input)
    when "5"
      get_top_three_movies_from_db
      options
    when "6"
      find_top_3_gross
      spacing
      # method created by M||A
      options
    when "7"
      get_all_parental_ratings_from_db
      get_movie_info_from_db_by_parental_rating
      options
    when "8"

      get_movie_info_from_db_by_parental_rating
    when "8"
      decade_by_year
    when "9" # 9. Search Movie by by Studio."
      spacing
      print_studio_list
      puts "="*45
      puts "Please enter a studio name: \n".upcase
      input = gets.chomp.downcase
      goodbye if input == "e"
      studio_movies(input)
      options
    else
      puts "Not a valid option. Please try again: \n".upcase
      options
  end
end

def get_movie_info_from_db
  Movie.select(:id, :title).each do |movie_obj|
    puts "#{movie_obj.id}. #{movie_obj.title}"
  end
  spacing
  options
end

def get_actor_info_from_db
  Actor.select(:name, :id).each do |actor_obj|
    puts "#{actor_obj.id}. #{actor_obj.name}" if actor_obj.name != "N/A"
  end
  spacing
  options
end

def get_director_info_from_db
  Director.select(:name, :id).each do |director_obj|
     puts "#{director_obj.id}. #{director_obj.name}" if director_obj.name != "N/A"
  end
  spacing
  options
end

def get_movie_info_online(input) #number2
  req = RestClient.get("http://www.omdbapi.com/?t=#{input}&apikey=485b50f7")
  res = JSON.parse(req)
  check = Movie.find_by(title: res["Title"])
binding.pry


  title = res["Title"]
  year = res["Year"].to_i
  rated = res["Rated"]
  released = res["Released"]
  genre = res["Genre"]
  director = res["Director"].split(",").first
  plot = res["Plot"]
  rating = res["imdbRating"].to_f
  !res["BoxOffice"] == nil? ? box_office = res["BoxOffice"] : box_office = "N/A"
  !res["Production"] == nil? ? production = res["Production"].gsub(/[^A-Za-z 0-9]/, "") : production = "other"

  new_film = Movie.find_or_create_by(title: title, year: year, rated: rated, released: released, genre: genre, plot: plot, rating: rating, box_office: box_office, production: production)

  new_dir = Director.find_or_create_by(name: director)
  directed_movie_join = DirectedMovie.find_or_create_by(director_id: new_dir, movie_id: new_film)

  actors = movie["Actors"].split(", ")
    actors.each do |name|
      actor = Actor.find_or_create_by(name: name)
      cast_join = Cast.find_or_create_by(actor_id: actor.id, movie_id: m.id)
    end
  new_film.print_info
end


def get_movies_by_actor_id(actor_id)
  actor_ids = Actor.select(:id).map do |actor_obj|
    actor_obj.id.to_s
  end

  if actor_id.empty? || !actor_ids.include?(actor_id)
    get_actor_info_from_db
    puts "Invalid entry. Please enter a number from the list: "
    get_movies_by_actor_id(gets.chomp)
  else
    actor_name = Actor.find(actor_id).name
    puts "#{actor_name} is part of:"
    movies = Movie.joins("INNER JOIN casts on movies.id = casts.movie_id AND casts.actor_id = #{actor_id}")
    movies.each do |movie_obj|
      puts movie_obj.title
    end
  end
end

def get_top_three_movies_from_db
  movies = Movie.order("rating DESC")
  puts "1. #{movies[0].title} - #{movies[0].rating}"
  puts "2. #{movies[1].title} - #{movies[1].rating}"
  puts "3. #{movies[2].title} - #{movies[2].rating}"
  spacing
end

def get_all_parental_ratings_from_db
  Movie.select(:rated).map do |movie_obj|
    movie_obj.rated
  end.uniq.each do |parental_rating|
    puts parental_rating
  end
end

def get_movie_info_from_db_by_parental_rating
  puts "Please enter a rating: \n"
  input = input_goodbye_return
  movies = Movie.where("rated LIKE ?", "%#{input}%")

  if movies.empty? || input.empty?
    puts "This is not a valid option"
    get_all_parental_ratings_from_db
    puts "Please try again: \n"
    get_movie_info_from_db_by_parental_rating
  else
    spacing
    movies.each_with_index do |movie_obj, index|
      puts "#{index + 1}. #{movie_obj.title} - #{movie_obj.rated}"
    end
  end
end

def print_not_valid_option
  puts "="*45
  puts "\n"
  puts "\n"
  puts "="*45
  puts "Not a valid option.".upcase
  puts "Please try again: \n"
  puts "="*45
  sleep(2)
end

def print_studio_list
  m = Movie.all.map do |movie|
    movie.production
  end.uniq
  a = m.each_with_index do |prod, index|
    puts "#{index+1}. #{prod}"
  end
end

#RRR
def studio_movies
  input = input_goodbye_return
  movies = Movie.all.where("production LIKE ?", "%#{input}%")
  case movies
    when [] || nil
      print_not_valid_option
      print_studio_list
      puts "Please type a name from the list: "
      studio_movies

    else
      puts "*"*45
      puts "\n"
      movies.each_with_index do |movie, index|
        puts " #{index+1}. #{movie.title}"
      end
      puts "\n"
      sleep(2)
      options
  end
end

def find_top_3_gross #6
  response = Movie.where.not(box_office: [nil, ""])

  unsorted = response.each {|movie|
    movie.box_office = movie.box_office.gsub(/[^0-9 ]/i, '').to_i
  }
  sorted = unsorted.sort_by do |movie|
    movie[:box_office].to_i
  end
  result = sorted.reverse
  puts "The following are the top 3 grossing movies within our database: "
  puts "1. #{result[0].title}  || Gross Amount:  $#{result[0].box_office}"
  puts "2. #{result[1].title}  || Gross Amount:  $#{result[1].box_office}"
  puts "3. #{result[2].title}  || Gross Amount:  $#{result[2].box_office}"


end

def print_decade_example
  puts "\n"
  puts "\n"
  puts "*"*45
  puts "Please enter a year: \n".upcase

  puts "Enter a year and we will return \n"
  puts "any movies found within that decade.\n"
  puts "Example: 1995"
  puts "Will return all movies from 1990-1999.\n"
  puts "Enter (e) to EXIT || (r) Return to Main Menu."
  #goes to decade by year method
end

def not_valid_length #part of 8
  puts "Not a valid length.\n"
  decade_by_year
end

def input_goodbye_return
  input = gets.chomp
  goodbye if input == "e"
  options if input == "r"
  input
end

def decade_by_year # 8. Search Movie by by decade"
  print_decade_example
  input = input_goodbye_return
  binding.pry
  not_valid_length if input.length < 4 && input.length > 4
  array1 = input.split("")
  array2 = input.split("")
  array1[3] = "0"
  array2[3] = "9"
  zero = array1.join.to_i
  nine = array2.join.to_i
  results = Movie.all.where(
  "year > ? AND year < ?", zero, nine)
  case results
    when []
      puts "No Movies found for that year."
      puts "Please try again: \n"
      decade_by_year
    when nil
      puts "No Movies found for that year."
      puts "Please try again: \n"
      decade_by_year
    else
      puts "*"*45
      puts "\n"
      puts " YEAR RELEASED  ||    TITLE             |"
      results.each_with_index do |movie, index|
        puts " #{index+1}. #{movie.year} #{movie.title}"
    end
    puts "\n"
    sleep(2)
  end
end

  #DO NOT CALL RUN in here.
  def run
    welcome
    options
  end
