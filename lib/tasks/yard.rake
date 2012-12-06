if Rails.env.development?
  YARD::Rake::YardocTask.new do |yardoc|
    yardoc.options = ["--template-path", "./yard/custom_templates"]
  end
end
