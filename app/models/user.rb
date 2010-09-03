class User < ActiveRecord::Base
  has_many :user_friends
  has_many :user_locations
  has_many :user_invitations

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
#
#    def self.request(user_id,email,status)
#      user = User.find(:first,  :conditions => {:email => email})
#
#      return user
#    end

  

end
