class AddHasHsInfoToProtocols < ActiveRecord::Migration[5.1]
  def change
    add_column :protocols, :has_human_subject_info, :boolean
  end
end
