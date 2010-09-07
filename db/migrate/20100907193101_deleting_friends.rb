class DeletingFriends < ActiveRecord::Migration
  def self.up

    execute %Q{ ALTER TABLE `user_friends` MODIFY COLUMN `share` ENUM('0','1','2') DEFAULT 0 }

    execute %Q{ ALTER TABLE `user_friends` ADD COLUMN `deleted` ENUM('yes','no') NOT NULL DEFAULT 'no' AFTER `view` }
  end

  def self.down
  end
end
