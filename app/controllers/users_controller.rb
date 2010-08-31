class UsersController < ApplicationController

  def register_user
    user = User.new(:username => params[:username], :password => params[:password], :email => params[:email], :name => params[:name])
    if user.save!
      friends = [ { :name => "anil", :status => "77.583333", :latitude => "12.98333", :time => "10" },
                 { :name => "kumar", :status => "-76.21667", :latitude => "12.21667", :time => "44.95" } ]

      xml_output = buildxml_friends_list(friends)

      render :xml => xml_output
    end
  end

  def check_user
    user = User.check_user(params[:username], params[:password])

    if !user.blank?
      friends = [ { :name => "anil", :status => "77.583333", :latitude => "12.98333", :time => "10" },
                 { :name => "kumar", :status => "-76.21667", :latitude => "12.21667", :time => "44.95" } ]
               
      xml_output = buildxml_friends_list(friends)
        
      render :xml => xml_output
    else
      render :text => "false"
    end

  end

  private
  
  def buildxml_friends_list(list)
    doc = Builder::XmlMarkup.new( :target => out_string = "", :indent => 2 )
    doc.list {
      list.each{ |element_data|
        doc.root{
          doc.name( element_data[:name] )
          doc.status( element_data[:status] )
          doc.latitude( element_data[:latitude] )
          doc.time( element_data[:time] )
        }
      }
    }
    
    return out_string
  end

end
