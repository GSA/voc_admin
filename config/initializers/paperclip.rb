# Paperclip::Attachment.default_options.merge!(
#     :path => ":rails_root/exports/:basename.:extension",
#     :url => "/exports/:access_token/download"
# )

Paperclip.interpolates :access_token do |attachment, style|
  attachment.instance.access_token
end

Paperclip.options[:content_type_mappings] = {
  :csv => "application/octet-stream"
}
