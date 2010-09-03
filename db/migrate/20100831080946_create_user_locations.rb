class CreateUserLocations < ActiveRecord::Migration
  def self.up
    execute %Q{ CREATE TABLE  `user_locations` (
                `id` int(11) unsigned NOT NULL auto_increment,
                `user_id` int(11) unsigned NOT NULL,
                `current_lat` varchar(45) NOT NULL,
                `current_long` varchar(45) NOT NULL,
                `current_time` int(11) unsigned NOT NULL,
                PRIMARY KEY  (`id`),
                KEY `user_id` (`user_id`),
                CONSTRAINT `FK_user_locations_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
                ) ENGINE=InnoDB }

  end

  def self.down
    drop_table :user_locations
  end
end
