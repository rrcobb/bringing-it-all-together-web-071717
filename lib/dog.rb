class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    DB[:conn].execute('CREATE TABLE IF NOT EXISTS dogs(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, breed TEXT)')
  end

  def self.drop_table
    DB[:conn].execute('DROP TABLE IF EXISTS dogs')
  end

  def save
    if @id.nil?
      DB[:conn].execute('INSERT INTO dogs(name, breed) VALUES (?, ?)', @name, @breed)
      @id = DB[:conn].last_insert_row_id
      self
    else
      DB[:conn].execute('UPDATE dogs SET name = ?, breed = ? WHERE id = ?', @name, @breed, @id)
    end
  end

  alias_method :update, :save

  def self.create(hash)
    self.new(hash).save
  end

  def self.new_from_db(row)
    self.new(name: row[1], breed: row[2], id: row[0])
  end

  def self.where_by(hash)
    DB[:conn]
    .execute('SELECT * FROM dogs WHERE ' + hash.map { |k, v| "#{k} = ?" }.join(' AND '), *hash.values)
    .map { |row| self.new_from_db(row) }
  end

  def self.find_by(hash)
    self.where_by(hash).first
  end

  def self.find_by_id(id)
    self.find_by(id: id)
  end

  def self.find_or_create_by(hash)
    self.find_by(hash) || self.create(hash)
  end

  def self.find_by_name(name)
    self.find_by(name: name)
  end
end
