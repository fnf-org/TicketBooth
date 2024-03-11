# frozen_string_literal: true

class RemoveUnusedIndexesFromEventAdmin < ActiveRecord::Migration[6.0]
  def up
    if index_exists?(:event_admins, :user_id,
                     name: 'index_event_admins_on_user_id_only')
      remove_index :event_admins, column: [:user_id], name: 'index_event_admins_on_user_id_only'
    end

    if index_exists?(:event_admins, :event_id, name: 'index_event_admins_on_event_id')
      remove_index :event_admins, column: [:event_id], name: 'index_event_admins_on_event_id'
    end

    execute 'analyze event_admins'
  end

  def down
    unless index_exists?(:event_admins, :user_id, name: 'index_event_admins_on_user_id_only')
      add_index(:event_admins, [:user_id], name: 'index_event_admins_on_user_id_only')
    end

    unless index_exists?(:event_admins, :event_id, name: 'index_event_admins_on_event_id')
      add_index(:event_admins, [:event_id], name: 'index_event_admins_on_event_id')
    end

    execute 'analyze event_admins'
  end
end
