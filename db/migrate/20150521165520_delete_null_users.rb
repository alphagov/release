class DeleteNullUsers < ActiveRecord::Migration
  def change
    User.where(email: nil).delete_all
  end
end
