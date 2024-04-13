class AddJtiToUsers < ActiveRecord::Migration[7.1]
  def change
    # rubocop:disable Rails/NotNullColumn
    add_column :users, :jti, :string, null: false
    # rubocop:enable Rails/NotNullColumn
    add_index :users, :jti, unique: true
  end
end
