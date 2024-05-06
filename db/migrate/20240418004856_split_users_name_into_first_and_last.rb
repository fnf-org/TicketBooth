# frozen_string_literal: true

class SplitUsersNameIntoFirstAndLast < ActiveRecord::Migration[7.1]
  # rubocop: disable Rails/BulkChangeTable
  def up
    add_column :users, :first, :text
    add_column :users, :last, :text

    User.find_each do |user|
      next if user.name.blank?

      name_components = user.name.gsub(/^(Dr\.?|Esq\.?)\s?/, '').split(/\s+/)
      user.first = name_components.shift
      user.last = name_components.join(' ')
      execute "update users set first = '#{escape(user.first)}', last = '#{escape(user.last)})' where id = #{user.id}"
    end
  end

  def down
    remove_column(:users, :first)
    remove_column(:users, :last)
  end

  def escape(string)
    return string unless string.include?("'")

    string.gsub("'", "''")
  end
  # rubocop: enable Rails/BulkChangeTable
end
