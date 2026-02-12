class MakeDeliveryAndPromoNullable < ActiveRecord::Migration[8.0]
  def change
    change_column_null :orders, :delivery_type_id, true
    change_column_null :orders, :promo_code_id, true
  end
end
