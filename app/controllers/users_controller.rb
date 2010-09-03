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
#      friends = Array.new(){Hash.new}
#      friends = User.find_by_sql"SELECT u.`name`, u.`current_lat`, u.`current_long`, u.`current_time` FROM users u"
      friends =  [ { :name => "anil", :longitude => "77.583333", :latitude => "12.98333", :time => "10" },
                 { :name => "kumar", :longitude=> "-76.21667", :latitude => "12.21667", :time => "44.95" } ]
               
      xml_output = buildxml_friends_list(friends)
        
      render :xml => xml_output
    else
      render :text => "false"
    end

  end

  def accept_invite    
    user_status = UserInvitation.status(params[:user_id],params[:email],params[:status])
    

    if !user_status.blank?

      friends =  [ { :name => "anil", :longitude => "77.583333", :latitude => "12.98333", :time => "10" },
                 { :name => "kumar", :longitude=> "-76.21667", :latitude => "12.21667", :time => "44.95" } ]
               

      xml_output = buildxml_friends_list(friends)

      render :xml => xml_output


    else
      render :text => "blab"
    end
    
  end

  def addmyfriend
    
  end

  def adduser

  end

  def whereareyou
    user = User.location(params[:username])
    
  end

  def iamhere

  end

  def wherearemyfriends

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
