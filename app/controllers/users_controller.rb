class UsersController < ApplicationController

 
#*************************************************************************************************************************************************************************
  def register_user
    @user = User.new(:username => params[:username], :password => params[:password], :email => params[:email], :name => params[:name])
    if @user.save
      render :text => "your account is created"
    else
      error = ""
      if !@user.errors[:username].blank?
        error = @user.errors[:username]
      elsif !@user.errors[:email].blank?
        error = @user.errors[:email]
      end
      render :text => error
    end
  end


#*************************************************************************************************************************************************************************
  def check_user
    user = User.check_user(params[:username], params[:password])
    if !user.blank?
     friends = User.find_by_sql("select u.id, u.username, u.current_lat, u.current_long, u.current_time
                                 from user_friends uf
                                 join users u on uf.friend_id = u.id
                                 where uf.user_id = #{user.id} and uf.deleted = 'no' and uf.share = '1'")

      xml_output = buildxml_user_friends_list(friends, user.id)
      render :xml => xml_output
    else
      render :text => "false"
    end
  end


#*************************************************************************************************************************************************************************
  def list_view
    user = User.find_by_sql("select * from users where username ='#{params[:user]}'")[0]
    if !user.blank?
     friends = User.find_by_sql("select u.id, u.username, u.current_lat, u.current_long, u.current_time
                                 from user_friends uf
                                 join users u on uf.friend_id = u.id
                                 where uf.user_id = #{user.id} and uf.deleted = 'no' and uf.share = '1'")

      xml_output = buildxml_user_friends_list(friends, user.id)
      render :xml => xml_output
    else
      render :text => "false"
    end
  end


#*************************************************************************************************************************************************************************
  def following
    user = User.find_by_sql("select * from users where username ='#{params[:user]}'")[0]
    if !user.blank?
      following = User.find_by_sql("select u.username
                                        from user_friends uf
                                        join users u on uf.friend_id = u.id
                                        where uf.user_id = #{user.id} and uf.view = '2'")

       xml_output = buildxml_sharefriend_list(following)
       render :xml => xml_output
    else
      render :text => "false"
    end
  end


#*************************************************************************************************************************************************************************
  def requests
     user = User.find_by_sql("select * from users where username ='#{params[:user]}'")[0]
     if !user.blank?
       requests = UserInvitation.find_by_sql(" select u.username, ui.kind
                                                from user_invitations ui
                                                join users u on ui.user_id = u.id
                                                where ui.email = '#{user.email}' and  ui.status = 'pending'")

       xml_request = buildxml_requests_list(requests)
       render :xml => xml_request
     else
       render :text => "false"
     end
  end

 
#*************************************************************************************************************************************************************************
  # sending invitations to other users using their username
  def username_invites
   user = User.find_by_sql("select * from users where username ='#{params[:user]}'")[0]
   friend = User.find_by_sql("select * from users where username ='#{params[:friend]}'")[0]
   if !friend.blank?
     invitation = UserInvitation.find_by_sql("select * from user_invitations where user_id =#{user.id} and email ='#{friend.email}' and kind = '#{params[:kind]}' and status = 'pending'")[0]
     invitation1 = UserInvitation.find_by_sql("select * from user_invitations where user_id =#{user.id} and email ='#{friend.email}' and kind = '#{params[:kind]}' and status = 'accept'")[0]
     if params[:kind].to_s == "share"
       invitation2 = UserInvitation.find_by_sql("select * from user_invitations where user_id =#{friend.id} and email ='#{user.email}' and kind = 'view' and status = 'accept'")[0]
     elsif params[:kind].to_s == "view"
       invitation2 = UserInvitation.find_by_sql("select * from user_invitations where user_id =#{friend.id} and email ='#{user.email}' and kind = 'share' and status = 'accept'")[0]
     end

      if invitation.blank?
        if invitation1.blank?&&invitation2.blank?
         if user!=friend
          invite = UserInvitation.new(:user_id => user.id, :email => friend.email,:kind => params[:kind])
          if invite.save!
           render :text => "Request sent successfully"
          else
           render :text => "Request not sent"
          end
         else
          render :text => "You can't send request to yourself FOOL"
         end
       else
         render :text => "You are already friend with "+friend.username
       end
      else
        render :text => "Friend requested already"
      end

     else
      render :text => "frnd doesnt exists"
     end
  end


#*************************************************************************************************************************************************************************
  # sending invitations to other users using their email id
  def email_invites
   user = User.find_by_sql("select * from users where username ='#{params[:user]}'")[0]
   friend = User.find_by_sql("select * from users where email = '#{params[:email]}'")[0]
   if !friend.blank?
   invitation = UserInvitation.find_by_sql("select * from user_invitations where user_id =#{user.id} and email ='#{friend.email}' and kind = '#{params[:kind]}' and status = 'pending'")[0]
   invitation1 = UserInvitation.find_by_sql("select * from user_invitations where user_id =#{user.id} and email ='#{friend.email}' and kind = '#{params[:kind]}' and status = 'accept'")[0]
   if params[:kind].to_s == "share"
     invitation2 = UserInvitation.find_by_sql("select * from user_invitations where user_id =#{friend.id} and email ='#{user.email}' and kind = 'view' and status = 'accept'")[0]
   elsif params[:kind].to_s == "view"
     invitation2 = UserInvitation.find_by_sql("select * from user_invitations where user_id =#{friend.id} and email ='#{user.email}' and kind = 'share' and status = 'accept'")[0]
   end

    if invitation.blank?
      if invitation1.blank?&&invitation2.blank?
       if user!=friend
        invite = UserInvitation.new(:user_id => user.id, :email => friend.email,:kind => params[:kind])
        if invite.save!
         render :text => "Request sent successfully"
        else
         render :text => "Request not sent"
        end
       else
        render :text => "You can't send request to yourself FOOL"
       end
     else
       render :text => "You are already friend with "+friend.name
     end
    else
      render :text => "Friend requested already"
    end

   else
    render :text => "frnd doesnt exists"
   end
  end



#*************************************************************************************************************************************************************************
#**********************************************************************************************************
#**********************************************************************************************************8
#************************************************************************************************************
 def process_invitation
   user = User.find_by_sql("select * from users where username ='#{params[:user]}'")[0]
   friend = User.find_by_sql("select * from users where username ='#{params[:friend]}'")[0]
   if !params[:share].blank?

    invitation = UserInvitation.find_by_sql("select * from user_invitations where user_id =#{friend.id} and email ='#{user.email}' and status = 'pending' and kind = '#{params[:kind]}' ")[0]

     if !invitation.blank?
      if params[:share].to_s == "1"
       if params[:kind].to_s == "share"
        user_friend1 = UserFriend.find_by_sql("select * from user_friends where user_id=#{user.id} and friend_id=#{friend.id}")[0]
        user_friend2 = UserFriend.find_by_sql("select * from user_friends where user_id=#{friend.id} and friend_id=#{user.id}")[0]
        if user_friend1.blank?
          user_friend1 = UserFriend.new(:user_id => user.id, :friend_id => friend.id, :share => '1')
        else
          user_friend1.share = '1'
          user_friend1.deleted = 'no'
        end
        if user_friend2.blank?
          user_friend2 = UserFriend.new(:user_id => friend.id, :friend_id => user.id, :view => '2')
        else
          user_friend2.view = '2'
          user_friend2.deleted = 'no'
        end
        if user_friend1.save && user_friend2.save
          invitation.update_attributes(:status => "accept")
          render :text => "friend request accepted"
        else
          render :text => "false"
        end


        elsif params[:kind].to_s == "view"
          user_friend1 = UserFriend.find_by_sql("select * from user_friends where user_id=#{user.id} and friend_id=#{friend.id}")[0]
          user_friend2 = UserFriend.find_by_sql("select * from user_friends where user_id=#{friend.id} and friend_id=#{user.id}")[0]
          if user_friend1.blank?
            user_friend1 = UserFriend.new(:user_id => user.id, :friend_id => friend.id, :view => '2')
          else
            user_friend1.view = '2'
            user_friend1.deleted = 'no'
          end
          if user_friend2.blank?
            user_friend2 = UserFriend.new(:user_id => friend.id, :friend_id => user.id, :share => '1')
          else
            user_friend2.share = '1'
            user_friend2.deleted = 'no'
          end
          if user_friend1.save && user_friend2.save
            invitation.update_attributes(:status => "accept")
            render :text => "friend request accepted"
          else
            render :text => "false"
          end
        end
       else
          invitation.update_attributes(:status => "reject")
          render :text => "friend request rejected"
     end

     # for direct request sent using url.........no invitation sent in user_invitations table
   else
     if params[:share].to_s == "1"
       if params[:kind].to_s == "share"
        user_friend1 = UserFriend.find_by_sql("select * from user_friends where user_id=#{user.id} and friend_id=#{friend.id}")[0]
        user_friend2 = UserFriend.find_by_sql("select * from user_friends where user_id=#{friend.id} and friend_id=#{user.id}")[0]
        if user_friend1.blank?
          user_friend1 = UserFriend.new(:user_id => user.id, :friend_id => friend.id, :share => '1')
        else
          user_friend1.share = '1'
          user_friend1.deleted = 'no'
        end
        if user_friend2.blank?
          user_friend2 = UserFriend.new(:user_id => friend.id, :friend_id => user.id, :view => '2')
        else
          user_friend2.view = '2'
          user_friend2.deleted = 'no'
        end
        if user_friend1.save && user_friend2.save
          render :text => "friend request accepted"
        else
          render :text => "false"
        end


        elsif params[:kind].to_s == "view"
          user_friend1 = UserFriend.find_by_sql("select * from user_friends where user_id=#{user.id} and friend_id=#{friend.id}")[0]
          user_friend2 = UserFriend.find_by_sql("select * from user_friends where user_id=#{friend.id} and friend_id=#{user.id}")[0]
          if user_friend1.blank?
            user_friend1 = UserFriend.new(:user_id => user.id, :friend_id => friend.id, :view => '2')
          else
            user_friend1.view = '2'
            user_friend1.deleted = 'no'
          end
          if user_friend2.blank?
            user_friend2 = UserFriend.new(:user_id => friend.id, :friend_id => user.id, :share => '1')
          else
            user_friend2.share = '1'
            user_friend2.deleted = 'no'
          end
          if user_friend1.save && user_friend2.save
            render :text => "friend request accepted"
          else
            render :text => "false"
          end
        end
       else
         render :text => "friend request rejected"
     end


     end
    end
  end


#**********************************************************************************************************
#**********************************************************************************************************
#**********************************************************************************************************

#*************************************************************************************************************************************************************************
  # to stop sharing user location with any particular friend in following  list
  #
  def share_friend
    if !params[:share].blank?
      user = User.find_by_sql("select * from users where username ='#{params[:user]}'")[0]
      friend = User.find_by_sql("select * from users where username ='#{params[:friend]}'")[0]
       user_friend1 = UserFriend.find_by_sql("select * from user_friends where user_id=#{user.id} and friend_id=#{friend.id}")[0]
       user_friend2 = UserFriend.find_by_sql("select * from user_friends where user_id=#{friend.id} and friend_id=#{user.id}")[0]
      if !user_friend1.blank? && !user_friend2.blank?
        user_friend1.update_attributes(:view => params[:share])
        user_friend2.update_attributes(:share => params[:share])

        render :text => "sharing stopped"
      else
        render :text => "false"
      end
    end
  end


#*************************************************************************************************************************************************************************
  #to delete a friend from list view
  #
  def delete_friend
    user = User.find_by_sql("select * from users where username ='#{params[:user]}'")[0]
    friend = User.find_by_sql("select * from users where username ='#{params[:friend]}'")[0]
    delete_user1 = UserFriend.find_by_sql("select * from user_friends where  user_id=#{user.id} and friend_id=#{friend.id}")[0]
    delete_user2 = UserFriend.find_by_sql("select * from user_friends where  user_id=#{friend.id} and friend_id=#{user.id}")[0]
     if !delete_user1.blank? && !delete_user2.blank?
        delete_user1.update_attributes(:deleted => "yes",:share => '0', :view => '0')
        delete_user2.update_attributes(:deleted => "yes",:share => '0', :view => '0')
       
        render :text => "friend deleted"
      else
        render :text => "not deleted"
     end
  end


#*************************************************************************************************************************************************************************
  #to create a new entry in user_locations table everytime location is updated
  #it will also update users table with current location
  #
  def update_location
     user = User.find_by_sql("select * from users where username ='#{params[:user]}'")[0]
     if !user.blank?
       user_location = UserLocation.new(:user_id => user.id, :current_lat => params[:latitude], :current_long => params[:longitude], :current_time => params[:time].to_time.to_i)
       user.update_attributes(:current_lat =>params[:latitude], :current_long => params[:longitude], :current_time => params[:time].to_time.to_i)
       if user_location.save
         render :text => "location updated"
       else
         render :text => "error"
       end
     end
  end



  private
  


#*************************************************************************************************************************************************************************
  def buildxml_user_friends_list(list, user_id)
    doc = Builder::XmlMarkup.new( :target => out_string = "", :indent => 2 )
    doc.list {
      list.each{ |element_data|
        doc.root{
          i_am_friend = UserFriend.find_by_sql("select * from user_friends where user_id='#{element_data[:id]}' and friend_id='#{user_id}'")[0]
          friend_share = (i_am_friend.blank?)? 0 : i_am_friend.share.to_s
          new_time = Time.at(element_data[:current_time] ).to_datetime
          doc.username( element_data[:username] )
          doc.longitude( element_data[:current_lat] )
          doc.latitude( element_data[:current_long] )
          doc.time( new_time )
          doc.share(friend_share)
        }
      }
    }

    return out_string
  end

#*************************************************************************************************************************************************************************
  def buildxml_requests_list(list)
    doc = Builder::XmlMarkup.new( :target => out_string = "", :indent => 2 )
    doc.list {
      list.each{ |element_data|
        doc.root{
          doc.username( element_data[:username] )
          doc.kind(element_data[:kind] )
        }
      }
    }

    return out_string
  end


#*************************************************************************************************************************************************************************
  def buildxml_sharefriend_list(list)
    doc = Builder::XmlMarkup.new( :target => out_string = "", :indent => 2 )
    doc.list {
      list.each{ |element_data|
        doc.root{
          doc.username( element_data[:username] )
        }
      }
    }

    return out_string
  end
#*************************************************************************************************************************************************************************
 

#*************************************************************************************************************************************************************************
end