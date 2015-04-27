require 'sqlite3'
require 'date'
require_relative 'student_db'

class Student
  attr_accessor :id, :first_name, :last_name, :gender, :birthday, :email, :phone, :created_at, :updated_at
  def initialize(data = {})
    @first_name = data["first_name"]
    @last_name = data["last_name"]
    @gender = data["gender"] || nil
    @birthday = data["birthday"] || nil
    @email = data["email"] || nil
    @phone = data["phone"] || nil
    @created_at = DateTime.now
    @updated_at = DateTime.now
  end

  def self.all
    all_students = $db.execute("select * from students;")
    all_students.map {|each_hash| Student.new(each_hash)}
  end

  def self.where(field, value)
    all_students = $db.execute("select * from students where #{field}", value)
    all_students.map {|each_hash| Student.new(each_hash)}
  end

  def save
    if @id
      $db.execute(
      <<-QUERY_STRING
        update students
          set first_name = '#{@first_name}',
              last_name= '#{@last_name}',
              gender = '#{@gender}',
              birthday = '#{@birthday}',
              email = '#{@email}',
              phone = '#{@phone}',
              created_at = '#{@created_at}',
              updated_at = '#{@updated_at}'
        where id = #{@id};
      QUERY_STRING
     )
    else
     $db.execute(
       <<-QUERY_STRING
        insert into students (first_name, last_name, gender, birthday, email, phone, created_at, updated_at)
       values('#{@first_name}', '#{@last_name}', '#{@gender}', '#{@birthday}', '#{@email}', '#{@phone}', '#{@created_at}', '#{@updated_at}');
      QUERY_STRING
     )
     @id = $db.last_insert_row_id
    end
  end

  def delete
    $db.execute(
    <<-QUERY_STRING
      delete from students where id = #{@id}
    QUERY_STRING
    )
  end

  def self.find(number)
    if number == 0 || number > $db.last_insert_row_id
      return nil
    else
    Student.new($db.execute(
    <<-QUERY_STRING
      select * from students where id = #{number};
    QUERY_STRING
    ).first)
    end
  end

  def self.find_by_first_name(first_name)
    Student.new($db.execute(
    <<-QUERY_STRING
      select * from students where first_name = '#{first_name}';
    QUERY_STRING
    ).first)
  end

  def self.all_by_birthday
    all_students = $db.execute("select * from students order by birthday;")
    all_students.map {|each_hash| Student.new(each_hash)}
        # p all_students
  end

end
