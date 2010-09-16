class ChangingViewType < ActiveRecord::Migration
  def self.up

     execute %Q{ ALTER TABLE `user_friends` MODIFY COLUMN `view` ENUM('0','2') CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT 0}
  end

  def self.down
  end
end
