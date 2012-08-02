class AddAttachmentDocumentToExports < ActiveRecord::Migration
  def self.up
    change_table :exports do |t|
      t.has_attached_file :document
    end
  end

  def self.down
    drop_attached_file :exports, :document
  end
end
