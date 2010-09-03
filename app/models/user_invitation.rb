class UserInvitation < ActiveRecord::Base
  belongs_to :user

  attr_reader :status

 def self.status(user_id,email,status)
   user_status = UserInvitation.find(:first,  :conditions => {:email => email})
   user_status.update_attributes(:status => status)
  # current_status = UserInvitation.find_by_sql "SELECT u.`status` FROM user_invitations u Where u.email = email"
   
    if !user_status.blank?
      user_friend = UserFriend.addfriend(user_id)
      
    
    end
      
  end

end
