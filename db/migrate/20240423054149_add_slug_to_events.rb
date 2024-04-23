# frozen_string_literal: true

class AddSlugToEvents < ActiveRecord::Migration[7.1]
  def up
    add_column :events, :slug, :text

    Event.find_each do |event|
      event_name = event.name
      if event_name.blank?
        event_name = 'No Name'
        execute "update events set name = '#{event_name}' where id = #{event.id}"
      end

      slug = event_name.parameterize
      execute "update events set slug = '#{slug}' where id = #{event.id}"
    end
  end

  def down
    remove_column(:events, :slug)
  end
end
