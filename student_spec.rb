require_relative 'student'

describe Student do

  before(:each) do
    $db.transaction
    $db.execute("DELETE FROM students")
  end

  after(:each) do
    $db.rollback
  end

  let(:mikee_data) do
    { "first_name" => "Mikee",
      "last_name"  => "Pourhadi",
      "gender"     => "Male",
      "birthday"   => "1985-10-25",
      "email"      => "mikeepourhadi@gmail.com",
      "phone"      => "630-363-6640" }
  end

  let(:mikee) do
    mikee = Student.new(mikee_data)
    mikee.save
    mikee
  end

  let(:mikee_2_data) do
    { "first_name" => "Mikee",
      "last_name"  => "Baker",
      "gender"     => "Male",
      "birthday"   => "1987-11-05",
      "email"      => "matt@devbootcamp.com",
      "phone"      => "503-333-7740" }
  end

  let(:other_mikee) do
    student = Student.new(mikee_2_data)
    student.save
    student
  end

  let(:not_mikee_data) do
    { "first_name" => "Susie",
      "last_name"  => "Smith",
      "gender"     => "Female",
      "birthday"   => "1989-11-05",
      "email"      => "matt@devbootcamp.com",
      "phone"      => "503-333-7740" }
  end

  let(:not_mikee) do
    student = Student.new(not_mikee_data)
    student.save
    student
  end


  describe "#save" do
    context "record not in the database" do
      let(:unsaved_student) { Student.new(mikee_data) }

      it "saves to the database" do
        expect { unsaved_student.save }.to change { $db.execute("SELECT * FROM students WHERE first_name = ?", 'Mikee').count }.from(0).to(1)
      end

      describe "assigning the id" do
        it "has no id before being saved" do
          expect(unsaved_student.id).to be_nil
        end

        it "is assigned an id after save" do
          unsaved_student.save
          expect(unsaved_student.id).to eq $db.last_insert_row_id
        end
      end
    end

    context "record exists in the database" do
      it "updates the database columns with the attributes of the object" do
        # Get the id of the mikee Ruby object
        mikee_original_id = mikee.id

        # Change the first_name attribute in the Ruby object
        mikee.first_name = "Michael"

        expect { mikee.save }.to change { $db.execute("select * from students where id = ? AND first_name = ?", mikee_original_id, "Michael").count }.from(0).to(1)
      end

      it "does not alter the id" do
        expect { mikee.save }.to_not change { mikee.id }
      end
    end
  end

  describe ".find" do
    context "when a record with the given id is in the database" do
      it "returns a student" do
        found_student = Student.find(mikee.id)
        expect(found_student).to be_a Student
      end

      it "allows me to find a unique student by id" do
        found_student = Student.find(mikee.id)
        expect(found_student.first_name).to eq mikee.first_name
      end
    end

    context "when no record with the given id is in the database" do
      it "returns nothing" do
        expect(Student.find 0).to be_nil
      end
    end
  end

  describe "#delete" do
    it "removes the database record associated with the student from the database" do
      select_mikees = Proc.new { $db.execute("SELECT * FROM students WHERE first_name = ?", mikee.first_name) }

      expect { mikee.delete }.to change { select_mikees.call.count }.from(1).to(0)

    end
  end

  describe ".all" do
    before(:each) do
      saved_students = [mikee, other_mikee]
    end

    it "retrieves all students at once" do
      expect(Student.all.count).to eq $db.execute("SELECT * FROM students").count
    end

    it "returns a collection of student objects" do
      Student.all.each do |student|
        expect(student).to be_an_instance_of Student
      end
    end
  end

  describe ".find_by_first_name" do
    before(:each) do
      saved_students = [mikee, not_mikee]
    end

    it "returns a student" do
      expect(Student.find_by_first_name 'Mikee').to be_a Student
    end

    it "retrieves a student with the desired first name" do
      expect(Student.find_by_first_name('Mikee').first_name).to eq "Mikee"
    end
  end

  describe ".where" do
    before(:each) do
      saved_students = [mikee, other_mikee, not_mikee]
    end

    it "retrieves students by any attribute" do
      expected_students = [mikee, other_mikee]
      found_students = Student.where("first_name = ?", mikee.first_name)

      expect(found_students.count).to eq expected_students.count
    end

    it "returns a collection of student objects" do
      Student.where("first_name = ?", mikee.first_name).each do |student|
        expect(student).to be_an_instance_of Student
      end
    end
  end

  describe ".find_all_by_birthday" do
    before(:each) do
      @saved_students = [mikee, not_mikee, other_mikee]
    end

    it "returns a collection of student objects" do
      Student.all_by_birthday.each do |student|
        expect(student).to be_an_instance_of Student
      end
    end

    it "retrieves all student records" do
      expect(Student.all_by_birthday.count).to eq $db.execute("SELECT * FROM students").count
    end

    it "orders students by birthday oldest to youngest" do
      oldest_student = @saved_students.min_by(&:birthday)
      youngest_student = @saved_students.max_by(&:birthday)

      expect(Student.all_by_birthday.first.last_name).to eq oldest_student.last_name
      expect(Student.all_by_birthday.last.last_name).to eq youngest_student.last_name
    end
  end
end
