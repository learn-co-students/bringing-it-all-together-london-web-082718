require 'pry'

class Dog

  attr_accessor :id, :name, :breed

  def initialize(name:, breed:, id: nil)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name STRING, breed STRING)"

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"

    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else

      sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"

      DB[:conn].execute(sql, self.name, self.breed)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end

    self
  end

  def self.find_or_create_by(name:, breed:)

  	dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)[0]
    if dog
  	  Dog.new(name: dog[1], breed: dog[2], id: dog[0])
  	else
  	  self.create(name: name, breed: breed)
  	end

  end

  def self.create(name:, breed:)
  	dog = Dog.new(name: name, breed: breed)
  	dog.save
  	dog
  end

  def update
  	sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
  	DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"

    dog = DB[:conn].execute(sql, id)[0]
    Dog.new(name: dog[1], breed: dog[2], id: dog[0])
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"

    dog = DB[:conn].execute(sql, name)[0]
    Dog.new(name: dog[1], breed: dog[2], id: dog[0])

  end

  def self.new_from_db(row)

    Dog.new(name: row[1], breed: row[2], id: row[0])
  end

end
