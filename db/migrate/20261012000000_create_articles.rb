class CreateArticles < ActiveRecord::Migration[8.0]
  def change
    create_table :articles do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.string :excerpt, limit: 320
      t.text :body, null: false
      t.string :status, null: false, default: "draft"
      t.string :content_format, null: false, default: "markdown"
      t.datetime :published_at
      t.timestamps
    end
    add_index :articles, :slug, unique: true
    add_index :articles, [:status, :published_at]
  end
end
