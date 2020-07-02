class AddStatusDefaults < ActiveRecord::Migration[6.0]
  def change
    change_column_default :donors, :account_status, from: 'pending', to: AccountStatus::PROCESSING
    change_column_default :clients, :account_status, from: 'pending', to: AccountStatus::PROCESSING
  end
end
