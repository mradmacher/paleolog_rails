def fake_email
  email = nil
  loop do
    email = Faker::Internet.email
    break unless User.where( :email => email ).exists?
  end
  email
end

def fake_string( klass, method, min, max )
  name = nil
  loop do
    name = Faker::Lorem.characters( Random.new.rand( min..max ) )
    break unless klass.where( method => name ).exists?
  end
  name
end

Sham.config( User ) do |c|
  c.attributes do
    { :name => fake_string( User, :name, User::NAME_MIN_LENGTH, User::NAME_MAX_LENGTH ),
      :email => fake_email,
      :login => fake_string( User, :login, User::LOGIN_MIN_LENGTH, User::LOGIN_MAX_LENGTH ),
      :password => 'passwd123!',
      :password_confirmation => 'passwd123!'
    }
  end
end

Sham.config( Group ) do |c|
  c.attributes do
    { :name => fake_string( Group, :name, Group::NAME_MIN_LENGTH, Group::NAME_MAX_LENGTH ) }
  end
end

Sham.config( ResearchParticipation ) do |c|
  c.attributes do
    { :user => Sham::Nested.new( User ),
      :well => Sham::Nested.new( Well ),
      :manager => false
    }
  end
end

Sham.config( Specimen ) do |c|
  c.attributes do
    { :name => fake_string( Specimen, :name, Specimen::NAME_MIN_LENGTH, Specimen::NAME_MAX_LENGTH ),
      :verified => [true, false][Random.new.rand( 0..1 )],
      :group => Sham::Nested.new( Group )
    }

  end
end

Sham.config( Region ) do |c|
  c.attributes do
    { :name => fake_string( Region, :name, Region::NAME_MIN_LENGTH, Region::NAME_MAX_LENGTH ) }
  end
end

Sham.config( Well ) do |c|
  c.attributes do
    { :name => fake_string( Well, :name, Well::NAME_MIN_LENGTH, Well::NAME_MAX_LENGTH ),
      :region => Sham::Nested.new( Region )
    }
  end
end

Sham.config( Counting ) do |c|
  c.attributes do
    { :name => fake_string( Counting, :name, Counting::NAME_MIN_LENGTH, Counting::NAME_MAX_LENGTH ),
      :well => Sham::Nested.new( Well )
    }
  end
end

Sham.config( Sample ) do |c|
  c.attributes do
    { :name => fake_string( Sample, :name, Sample::NAME_MIN_LENGTH, Sample::NAME_MAX_LENGTH ),
      :well => Sham::Nested.new( Well ),
      :top_depth => -20.0,
      :bottom_depth => -45.5
    }
  end
end

Sham.config( Occurrence ) do |c|
  well = Well.sham!

  c.attributes do
    { :specimen => Sham::Nested.new( Specimen ),
      :quantity => (1..100).to_a.sample,
      :rank => Occurrence.maximum( :rank ).nil? ? 0 : Occurrence.maximum( :rank ) + 1,
      :status => Occurrence::NORMAL,
      :sample => Sham::Nested.new( Sample, well: well ),
      :counting => Sham::Nested.new( Counting, well: well )
    }
  end
end

Sham.config( Comment ) do |c|
  c.attributes do
    { :message => 'Some message',
      :user => Sham::Nested.new( User ),
      :commentable_id => Sham::Nested.new( Specimen ),
      :commentable_type => 'Specimen'
    }
  end
end

Sham.config( Field ) do |c|
  c.attributes do
    {
      :group => Sham::Nested.new( Group ),
      :name => fake_string( Field, :name, 1, Field::NAME_MAX_LENGTH )
    }
  end
end

Sham.config( Choice ) do |c|
  c.attributes do
    {
      :field => Sham::Nested.new( Field ),
      :name => fake_string( Choice, :name, 1, Choice::NAME_MAX_LENGTH )
    }
  end
end

Sham.config( Feature ) do |c|
  field = Field.sham!
  c.attributes do
    {
      :choice => Sham::Nested.new( Choice, field: field ),
      :specimen => Sham::Nested.new( Specimen, group: field.group )
    }
  end
end

