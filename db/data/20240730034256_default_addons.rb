# frozen_string_literal: true

class DefaultAddons < ActiveRecord::Migration[7.1]
  def up
    Addon.create category: Addon::CATEGORY_PASS, name: 'Early Arrival', default_price: 0
    Addon.create category: Addon::CATEGORY_PASS, name: 'Late Departure', default_price: 30
    Addon.create category: Addon::CATEGORY_CAMP, name: 'Car Camping', default_price: 50
    Addon.create category: Addon::CATEGORY_CAMP, name: 'RV under 20ft', default_price: 100
    Addon.create category: Addon::CATEGORY_CAMP, name: 'RV 20ft to 25ft', default_price: 125
    Addon.create category: Addon::CATEGORY_CAMP, name: 'RV over 25ft', default_price: 150
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
