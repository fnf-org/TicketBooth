# frozen_string_literal: true

class MakeEventSlugsUnique < ActiveRecord::Migration[7.1]
  def change
    unique_slugs = {}
    Event.find_each do |event|
      count = unique_slugs[event.slug] || 0
      if count.positive?
        event.slug = event.slug + "-#{count + 1}"
        unique_slugs[event.slug] += 1
        event.save!
      end
    end
  end
end
