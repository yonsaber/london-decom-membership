class AddFrequentlyAskedQuestions < ActiveRecord::Migration[8.1]
  def change
    create_table :frequently_asked_categories do |t|
      t.string :name

      t.timestamps
    end

    create_table :frequently_asked_questions do |t|
      t.string :question
      t.string :answer

      t.references :category, null: true, foreign_key: { to_table: :frequently_asked_categories, on_delete: :nullify }
      t.references :created_by, null: true, foreign_key: { to_table: :users, on_delete: :nullify }
      t.references :updated_by, null: true, foreign_key: { to_table: :users, on_delete: :nullify }

      t.timestamps
    end
  end
end
