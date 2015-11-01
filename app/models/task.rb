class Task < ActiveRecord::Base
  belongs_to :project
  belongs_to :admin_user
 
  validates :title, :project_id, :admin_user_id, :presence => true
  validates :is_done, :inclusion => { :in => [true, false] }
end
