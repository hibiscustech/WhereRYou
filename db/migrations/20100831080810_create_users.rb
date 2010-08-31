class CreateUsers < ActiveRecord::Migration
  def self.up
    execute %Q{  CREATE TABLE  `users` (
             `id` int(11) unsigned NOT NULL auto_increment,
              `name` varchar(45) NOT NULL,
              `username` varchar(45) default NULL,
              `email` varchar(45) default NULL,
              `password_hash` varchar(255) default NULL,
              `password_salt` varchar(255) default NULL,
              `current_lat` varchar(45) ,
              `current_long` varchar(45) ,
              `current_time` int(11) unsigned ,
               PRIMARY KEY  (`id`)
               ) ENGINE=InnoDB }

  end

  def self.down
    drop_table :users
  end
end
