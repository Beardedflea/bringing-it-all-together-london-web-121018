require_relative "../config/environment.rb"

require 'pry'


class Dog

    attr_accessor :name, :breed, :id

    @@all = []

    def initialize(params)
        @name = params[:name]
        @breed = params[:breed]
        @id = params[:id]
        @@all << self
    end

    def self.new_from_db(row)
        params = {id: row[0], name: row[1], breed: row[2]}
        Dog.new(params)
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        result = DB[:conn].execute(sql, name)[0]
        Dog.new_from_db(result)
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        result = DB[:conn].execute(sql, id)[0]
        Dog.new_from_db(result)
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !dog.empty?

            dog_data = dog[0]
            dog = Dog.new_from_db(dog_data)
        else
          dog = self.create(name: name, breed: breed)
        end
        dog
      end 

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT
        )
        SQL
    
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
          INSERT INTO dogs (name, breed) 
          VALUES (?, ?)
        SQL
    
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
      end

      def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
      end

      def self.create(params)
        dog = Dog.new(params)
        dog.save
      end

      def self.all  
        @@all 
      end


end

fido = Dog.new(name: "Fido", breed: "lab")

repeat = Dog.new(name: "Fido", breed: "lab")

larry = Dog.new(name: "Larry", breed: "nerd")

larrybreed = Dog.new(name: "Larry", breed: "different")

tom = Dog.new(name: "Tom", breed: "corgi")



Dog.all.each do |dog|
    puts dog.id
end
