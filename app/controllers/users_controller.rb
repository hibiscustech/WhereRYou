class UsersController < ApplicationController


  def register_user
    @user = User.new(:username => params[:username], :password => params[:password], :email => params[:email], :name => params[:name])
    if @user.save
      render :text => "your account is created"
    else
      render :action => 'error'
    end
  end

  
  def check_user
    user = User.check_user(params[:username], params[:password])
    if !user.blank?
     friends = User.find_by_sql("select u.name, u.current_lat, u.current_long, u.current_time
                                 from user_friends uf
                                 join users u on uf.friend_id = u.id
                                 where uf.user_id = #{user.id} and uf.deleted = 'no' and uf.share = '1'")

      xml_output = buildxml_friends_list(friends)
      render :xml => xml_output
    else
      render :text => "false"
    end
  end


  def username_invites
   user = User.find_by_sql("select * from users where username ='#{params[:user]}'")[0]
   friend = User.find_by_sql("select * from users where username ='#{params[:friend]}'")[0]
   if !friend.blank?
   invite = UserInvitation.new(:user_id => user.id, :email => friend.email,:kind => params[:kind])
   if invite.save!
     render :text => "Request sent successfully"
   else
     render :text => "Request not sent"
   end
   else
     render :text => "frnd doesnt exists"
   end
  end


  def email_invites
    user = User.find_by_sql("select * from users where username ='#{params[:user]}'")[0]
    friend = User.find_by_sql("select * from users where email = '#{params[:email]}'")[0]
    if !friend.blank?
      invite = UserInvitation.new(:user_id => user.id, :email => friend.email,:kind => params[:kind])
      if invite.save!
       render :text => "Request sent successfully"
      else
       render :text => "Request not sent"
      end
     else
       render :text => "frnd doesnt exists"
    end
  end


  def process_invitation
   user = User.find_by_sql("select * from users where username ='#{params[:user]}'")[0]
   friend = User.find_by_sql("select * from users where username ='#{params[:friend]}'")[0]
   invitation = UserInvitation.find_by_sql("select * from user_invitations where user_id =#{friend.id} and email ='#{user.email}'")[0]

    requests = UserInvitation.find_by_sql(" select u.name, ui.kind
                                            from user_invitations ui
                                            join users u on ui.user_id = u.id
                                            where ui.email = '#{user.email}' and  ui.status = 'pending'")

    xml_request = buildxml_requests_list(requests)
    
    
    if !params[:share].blank?
      if params[:share].to_s == "1"
        user_friend1 = UserFriend.find_by_sql("select * from user_friends where user_id=#{user.id} and friend_id=#{friend.id}")[0]
        user_friend2 = UserFriend.find_by_sql("select * from user_friends where user_id=#{friend.id} and friend_id=#{user.id}")[0]
        if user_friend1.blank?
          user_friend1 = UserFriend.new(:user_id => user.id, :friend_id => friend.id, :share => params[:share])
        else
          user_friend1.share = params[:share]
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
          #render :text => "friend request accepted"
          render :xml => xml_request
        else
          render :text => "false"
        end


        elsif params[:share].to_s == "2"
          user_friend1 = UserFriend.find_by_sql("select * from user_friends where user_id=#{user.id} and friend_id=#{friend.id}")[0]
          user_friend2 = UserFriend.find_by_sql("select * from user_friends where user_id=#{friend.id} and friend_id=#{user.id}")[0]
          if user_friend1.blank?
            user_friend1 = UserFriend.new(:user_id => user.id, :friend_id => friend.id, :view => params[:share])
          else
            user_friend1.view = params[:share]
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
            render :xml => xml_request
          else
            render :text => "false"
          end
        else
          invitation.update_attributes(:status => "reject")
          render :text => "friend request rejected"
      end
     end
  end


  def share_friend
    if !params[:share].blank?
      user = User.find_by_sql("select * from users where username ='#{params[:user]}'")[0]
      friend = User.find_by_sql("select * from users where username ='#{params[:friend]}'")[0]
       user_friend1 = UserFriend.find_by_sql("select * from user_friends where user_id=#{user.id} and friend_id=#{friend.id}")[0]
       user_friend2 = UserFriend.find_by_sql("select * from user_friends where user_id=#{friend.id} and friend_id=#{user.id}")[0]
      if !user_friend1.blank? && !user_friend2.blank?
        user_friend1.update_attributes(:view => params[:share])
        user_friend2.update_attributes(:share => params[:share])
        following = User.find_by_sql("select u.name
                                      from user_friends uf
                                      join users u on uf.friend_id = u.id
                                      where uf.user_id = #{user.id} and uf.view = '2'")

        xml_output = buildxml_sharefriend_list(following)
        render :xml => xml_output
      else
        render :text => "false"
      end
    end
  end


  def delete_friend
    user = User.find_by_sql("select * from users where username ='#{params[:user]}'")[0]
    friend = User.find_by_sql("select * from users where username ='#{params[:friend]}'")[0]
    delete_user1 = UserFriend.find_by_sql("select * from user_friends where  user_id=#{user.id} and friend_id=#{friend.id}")[0]
    delete_user2 = UserFriend.find_by_sql("select * from user_friends where  user_id=#{friend.id} and friend_id=#{user.id}")[0]
     if !delete_user1.blank? && !delete_user2.blank?
        delete_user1.update_attributes(:deleted => "yes",:share => '0', :view => '0')
        delete_user2.update_attributes(:deleted => "yes",:share => '0', :view => '0')
       
        friends = User.find_by_sql("select u.name, u.current_lat, u.current_long, u.current_time
                                   from user_friends uf
                                   join users u on uf.friend_id = u.id
                                   where uf.user_id = #{user.id} and uf.deleted = 'no' and uf.share = '1'")
      
        xml_output = buildxml_friends_list(friends)
        render :xml => xml_output
      else
        render :text => "not deleted"
     end
  end


  def update_location
     user = User.find_by_sql("select * from users where username ='#{params[:user]}'")[0]
     if !user.blank?
       user_location = UserLocation.new(:user_id => user.id, :current_lat => params[:latitude], :current_long => params[:longitude], :current_time => params[:time])
       user.update_attributes(:current_lat =>params[:latitude], :current_long => params[:longitude], :current_time => params[:time])
       if user_location.save
         render :text => "location updated"
       else
         render :text => "error"
       end
     end
  end


  private
  
  def buildxml_friends_list(list)
    doc = Builder::XmlMarkup.new( :target => out_string = "", :indent => 2 )
    doc.list {
      list.each{ |element_data|
        doc.root{
          doc.name( element_data[:name] )
          doc.longitude( element_data[:current_lat] )
          doc.latitude( element_data[:current_long] )
          doc.time( element_data[:current_time] )
          doc.share( element_data[:share] )
        }
      }
    }
    
    return out_string
  end


  def buildxml_requests_list(list)
    doc = Builder::XmlMarkup.new( :target => out_string = "", :indent => 2 )
    doc.list {
      list.each{ |element_data|
        doc.root{
          doc.name( element_data[:name] )
          doc.kind(element_data[:kind] )
        }
      }
    }

    return out_string
  end


  def buildxml_sharefriend_list(list)
    doc = Builder::XmlMarkup.new( :target => out_string = "", :indent => 2 )
    doc.list {
      list.each{ |element_data|
        doc.root{
          doc.name( element_data[:name] )
        }
      }
    }

    return out_string
  end


end
