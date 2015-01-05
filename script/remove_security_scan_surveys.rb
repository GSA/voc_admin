Survey.where(description: "Security Testing").each {|survey| survey.update_attribute(:archived, true)}
