class User < ActiveRecord::Base
  has_many :user_friends
  has_many :user_locations
  has_many :user_invitations

#  validates_presence_of     :username
  validates_length_of       :username,    :within => 3..20
  validates_uniqueness_of   :username

  #validates_presence_of     :email
 # validates_length_of       :email,    :within => 6..100
  validates_uniqueness_of   :email
  #validates_format_of      :email

 # validates_length_of       :password,    :within => 4..40

  attr_reader :password

  def password=(pass)
    @password = pass
    salt = [Array.new(6){rand(256).chr}.join].pack("m").chomp
    self.password_salt, self.password_hash = salt, Digest::SHA256.hexdigest(pass + salt)
  end

  def self.check_user(username,password)
    user = User.find(:first, :conditions => { :username => username})

    if user.blank? || Digest::SHA256.hexdigest(password + user.password_salt) != user.password_hash
      return nil
    end

    return user
  end


  

end
