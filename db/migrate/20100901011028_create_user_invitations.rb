class CreateUserInvitations < ActiveRecord::Migration
  def self.up

       execute %Q{ CREATE TABLE `user_invitations` (
             `id` int(11) unsigned NOT NULL auto_increment,
             `user_id` int(11) unsigned NOT NULL,
             `email` varchar(45) default NULL,
             `status` ENUM('accept','reject','pending') DEFAULT 'pending',
              PRIMARY KEY  (`id`),
              KEY `user_id` (`user_id`),
              CONSTRAINT `FK_user_invitations_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
            ) ENGINE=InnoDB }
  end

  def self.down
    drop_table :user_invitations
  end
end
