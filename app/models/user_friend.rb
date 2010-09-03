class UserFriend < ActiveRecord::Base
  belongs_to :user

  def self.addfriend(user_id)
   user_friend = UserFriend.new(:friend_id => user_id, :share => '1',:user_id => 1)
  
  end
end
