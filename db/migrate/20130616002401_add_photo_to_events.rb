# frozen_string_literal: true

class AddPhotoToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :photo, :string
  end
end
