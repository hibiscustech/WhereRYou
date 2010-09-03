# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100901011028) do

  create_table "user_friends", :force => true do |t|
    t.integer "user_id",                                 :null => false
    t.integer "friend_id"
    t.string  "share",     :limit => 0, :default => "0"
  end

  add_index "user_friends", ["friend_id"], :name => "friend_id"
  add_index "user_friends", ["user_id"], :name => "user_id"

  create_table "user_invitations", :force => true do |t|
    t.integer "user_id",                                      :null => false
    t.string  "email",   :limit => 45
    t.string  "status",  :limit => 0,  :default => "pending"
  end

  add_index "user_invitations", ["user_id"], :name => "user_id"

  create_table "user_locations", :force => true do |t|
    t.integer "user_id",                    :null => false
    t.string  "current_lat",  :limit => 45, :null => false
    t.string  "current_long", :limit => 45, :null => false
    t.integer "current_time",               :null => false
  end

  add_index "user_locations", ["user_id"], :name => "friend_id"

  create_table "users", :force => true do |t|
    t.string  "name",          :limit => 45, :null => false
    t.string  "username",      :limit => 45
    t.string  "email",         :limit => 45
    t.string  "password_hash"
    t.string  "password_salt"
    t.string  "current_lat",   :limit => 45
    t.string  "current_long",  :limit => 45
    t.integer "current_time"
  end

end
