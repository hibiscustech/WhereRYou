class AlteringInvitationFriend < ActiveRecord::Migration
  def self.up
    execute %Q{ ALTER TABLE `whereryou_development`.`user_invitations` ADD COLUMN `kind` ENUM('share','view') AFTER `status` }

    execute %Q{ ALTER TABLE `whereryou_development`.`user_friends` ADD COLUMN `view` ENUM('0','1') DEFAULT 1 AFTER `share` }
  end

  def self.down
  end
end
