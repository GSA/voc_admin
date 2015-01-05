Survey.where(description: "Security Scan").each {|survey| survey.update_attribute(:archived, true)}
