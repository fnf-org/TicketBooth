class AddPhotoToEvents < ActiveRecord::Migration
  def change
    add_column :events, :photo, :string
  end
end
