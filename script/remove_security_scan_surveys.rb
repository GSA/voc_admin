Survey.where(description: "Security Testing").each {|survey| survey.update_attribute(:archived, true)}
Survey.where("name LIKE ?", "%Secruity Testing%").each {|survey| survey.update_attribute(:archived, true)}
