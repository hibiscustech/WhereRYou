class CreateUserFriends < ActiveRecord::Migration
  def self.up
    execute %Q{ CREATE TABLE `user_friends` (
             `id` int(11) unsigned NOT NULL auto_increment,
             `user_id` int(11) unsigned NOT NULL,
             `friend_id` int(11) unsigned default NULL,
             `share` ENUM('0','1') DEFAULT '0',
              PRIMARY KEY  (`id`),
              KEY `user_id` (`user_id`),
              KEY `friend_id` (`friend_id`),
              CONSTRAINT `FK_user_friends_1` FOREIGN KEY (`friend_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
            ) ENGINE=InnoDB           }

  end

  def self.down
    drop_table :user_friends
  end
end
