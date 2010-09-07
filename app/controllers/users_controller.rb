class UsersController < ApplicationController

  def register_user
    user = User.new(:username => params[:username], :password => params[:password], :email => params[:email], :name => params[:name])
    if user.save!
#      friends = [ { :name => "anil", :longitude => "77.583333", :latitude => "12.98333", :time => "10" },
#                 { :name => "kumar", :longitude => "-76.21667", :latitude => "12.21667", :time => "44.95" } ]
#
#      xml_output = buildxml_friends_list(friends)

      render :text => "true"
    end
    render :text => "false"
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

  def process_invitation
    user = User.find(params[:user_id])
    invitation = UserInvitation.find_by_sql("select * from user_invitations where user_id=#{params[:friend_id]} and email='#{user.email}'")[0]

    if !params[:share].blank?
      if params[:share].to_s == "1"
        user_friend1 = UserFriend.find_by_sql("select * from user_friends where user_id=#{params[:user_id]} and friend_id=#{params[:friend_id]}")[0]
        user_friend2 = UserFriend.find_by_sql("select * from user_friends where user_id=#{params[:friend_id]} and friend_id=#{params[:user_id]}")[0]
        if user_friend1.blank?
          user_friend1 = UserFriend.new(:user_id => params[:user_id], :friend_id => params[:friend_id], :share => params[:share])
        else
          user_friend1.share = params[:share]
        end
        if user_friend2.blank?
          user_friend2 = UserFriend.new(:user_id => params[:friend_id], :friend_id => params[:user_id], :share => params[:share])
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

    if !params[:view].blank?
      if params[:view].to_s == "1"
        user_friend1 = UserFriend.find_by_sql("select * from user_friends where user_id=#{params[:user_id]} and friend_id=#{params[:friend_id]}")[0]
        user_friend2 = UserFriend.find_by_sql("select * from user_friends where user_id=#{params[:friend_id]} and friend_id=#{params[:user_id]}")[0]
        if user_friend1.blank?
          user_friend1 = UserFriend.new(:user_id => params[:user_id], :friend_id => params[:friend_id], :view => params[:view])
        else
          user_friend1.share = params[:view]
        end
        if user_friend2.blank?
          user_friend2 = UserFriend.new(:user_id => params[:friend_id], :friend_id => params[:user_id], :view => params[:view])
        else
          user_friend2.share = params[:view]
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
    
  end 

  def share_friend
    if !params[:share].blank?
      user_friend = UserFriend.find_by_sql("select * from user_friends where user_id=#{params[:user_id]} and friend_id=#{params[:friend_id]}")[0]
      if !user_friend.blank?
        user_friend.update_attributes(:share => params[:share])
        render :text => "true"
      else
        render :text => "false"
      end
    end

  end


  def delete_friend
    delete_user1 = UserFriend.find_by_sql("select * from user_friends where  user_id=#{params[:user_id]} and friend_id=#{params[:friend_id]}")[0]
    delete_user2 = UserFriend.find_by_sql("select * from user_friends where  user_id=#{params[:friend_id]} and friend_id=#{params[:user_id]}")[0]
    if !delete_user1.blank?
      delete_user1.destroy
    end
    if !delete_user2.blank?
      delete_user2.destroy
    end
    
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
