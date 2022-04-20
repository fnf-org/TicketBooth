# frozen_string_literal: true

class AddPhotoToEvents < ActiveRecord::Migration
  def change
    add_column :events, :photo, :string
  end
end
