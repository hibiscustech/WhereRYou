class UsersController < ApplicationController


  def register_user
#    user1 = User.check_user(params[:username],params[:password])
    error = ""
    user = User.new(:username => params[:username], :password => params[:password], :email => params[:email], :name => params[:name])
    if user.save!
      render :text => "your account is created"
    else
      if !user.errors[:username].blank?
        error = "Username "+user.errors[:username][0]
        render :string => error
      end
      if !user.errors[:email].blank?
        error = "Email "+user.errors[:email][0]
        render :string => error
      end
      if !user.errors[:password].blank?
        error = "password "+user.errors[:password]
        render :string => error
      end
    end
  end
  
  def check_user
    user = User.check_user(params[:username], params[:password])

    if !user.blank?

      friends =  [ { :name => "anil", :longitude => "77.583333", :latitude => "12.98333", :time => "10" },
                 { :name => "kumar", :longitude=> "-76.21667", :latitude => "12.21667", :time => "44.95" } ]
               
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
#   parser = XML::SaxParser.file("E:/projects/WhereRYou/tmp/status.xml")
#   parser.parse
    xml_status = File.read('E:/projects/WhereRYou/tmp/status.xml')
    

    if !params[:share].blank?
      if params[:share].to_s == "1"
        user_friend1 = UserFriend.find_by_sql("select * from user_friends where user_id=#{user.id} and friend_id=#{friend.id}")[0]
        user_friend2 = UserFriend.find_by_sql("select * from user_friends where user_id=#{friend.id} and friend_id=#{user.id}")[0]
        if user_friend1.blank?
          user_friend1 = UserFriend.new(:user_id => user.id, :friend_id => friend.id, :share => params[:share])
        else
          user_friend1.share = params[:share]
        end
        if user_friend2.blank?
          user_friend2 = UserFriend.new(:user_id => friend.id, :friend_id => user.id, :share => params[:share])
        else
          user_friend2.share = params[:share]
        end
        if user_friend1.save && user_friend2.save
          invitation.update_attributes(:status => "accept")
          render :xml => xml_status
        else
          render :text => "false"
        end
      else
        invitation.update_attributes(:status => "reject")
        render :text => "true"

       end

        elsif params[:share].to_s == "2"
          user_friend1 = UserFriend.find_by_sql("select * from user_friends where user_id=#{user.id} and friend_id=#{friend.id}")[0]
          user_friend2 = UserFriend.find_by_sql("select * from user_friends where user_id=#{friend.id} and friend_id=#{user.id}")[0]
          if user_friend1.blank?
            user_friend1 = UserFriend.new(:user_id => user.id, :friend_id => friend.id, :share => params[:share])
          else
            user_friend1.share = params[:share]
          end
          if user_friend2.blank?
            user_friend2 = UserFriend.new(:user_id => friend.id, :friend_id => user.id, :share => params[:share])
          else
            user_friend2.share = params[:share]
          end
          if user_friend1.save && user_friend2.save
            invitation.update_attributes(:status => "accept")
            render :text => "true"
          else
            render :text => "false"
          end
        else
          invitation.update_attributes(:status => "reject")
          render :text => "true"

     end
   end 

  def share_friend
    if !params[:share].blank?
      user = User.find_by_sql("select * from users where username ='#{params[:user]}'")[0]
      friend = User.find_by_sql("select * from users where username ='#{params[:friend]}'")[0]
      user_friend = UserFriend.find_by_sql("select * from user_friends where user_id=#{user.id} and friend_id=#{friend.id}")[0]
      if !user_friend.blank?
        user_friend.update_attributes(:share => params[:share])
        render :text => "true"
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
        delete_user1.update_attributes(:deleted => "yes")
        render :text => "true"
      else
        render :text => "false"
      end
#
#     if !delete_user2.blank? && delete_user2.save
#       delete_user2.update_attributes(:deleted => "yes")
#       render :text => "true"
#      else
#       render :text => "false"
#      end
# 
  end


  private
  
  def buildxml_friends_list(list)
    doc = Builder::XmlMarkup.new( :target => out_string = "", :indent => 2 )
    doc.list {
      list.each{ |element_data|
        doc.root{
          doc.name( element_data[:name] )
          doc.longitude( element_data[:longitude] )
          doc.latitude( element_data[:latitude] )
          doc.time( element_data[:time] )
        }
      }
    }
    
    return out_string
  end

end
